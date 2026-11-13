param(
    [string]$MCreatorRoot = "",
    [switch]$SkipJavaParse
)

$ErrorActionPreference = "Stop"

$pluginRoot = Split-Path -Parent $PSScriptRoot
$resources = Join-Path $pluginRoot "src\main\resources"
$fabric = Join-Path $resources "fabric-26.1.2"
$baseRoot = Join-Path $resources "fabric-26.1.2-base"
$baseDatapack = Join-Path $baseRoot "datapack"
$baseNeoforge = Join-Path $baseRoot "neoforge"
$failures = New-Object System.Collections.Generic.List[string]
$checks = 0

function Check([bool]$condition, [string]$message) {
    $script:checks++
    if (-not $condition) {
        $script:failures.Add($message)
        Write-Host "FAIL  $message" -ForegroundColor Red
    } else {
        Write-Host "OK    $message"
    }
}

function Get-Files([string]$root, [string[]]$pattern) {
    if (-not (Test-Path $root)) { return @() }
    return @(Get-ChildItem -LiteralPath $root -Recurse -File -Include $pattern)
}

function Get-TemplateNames([string]$root) {
    $names = New-Object System.Collections.Generic.List[string]
    foreach ($file in Get-Files $root "*.ftl") {
        $relative = $file.FullName.Substring($root.Length).TrimStart('\').Replace('\', '/')
        $names.Add($relative)
    }
    return $names
}

if (-not $MCreatorRoot) {
    $MCreatorRoot = Join-Path (Split-Path -Parent $pluginRoot) "MCreatorEAP2026344621"
}

Check (Test-Path (Join-Path $fabric "generator.yaml")) "main generator.yaml exists"
Check (-not (Test-Path (Join-Path $baseDatapack "generator.yaml"))) "embedded datapack base has no generator.yaml"
Check (-not (Test-Path (Join-Path $baseNeoforge "generator.yaml"))) "embedded NeoForge base has no generator.yaml"

$generatorYaml = Get-Content -LiteralPath (Join-Path $fabric "generator.yaml") -Raw
Check ($generatorYaml -match "fabric-26\.1\.2-base/datapack") "generator.yaml imports the namespaced datapack base"
Check ($generatorYaml -match "fabric-26\.1\.2-base/neoforge") "generator.yaml imports the namespaced NeoForge base"
Check ($generatorYaml -match "buildfileversion:\s*0\.155\.3") "generator.yaml uses Fabric API 0.155.3"

$pluginJson = Get-Content -LiteralPath (Join-Path $resources "plugin.json") -Raw
Check ($pluginJson -match '"id":\s*"generator-fabric-\$\{mcVersion\}"') 'plugin.json uses generator-fabric-${mcVersion}'
Check ($pluginJson -match '"author":\s*"LitQA"') "plugin.json author is LitQA"
Check ($pluginJson -match '\$\{supportedVersion\}') "plugin.json contains the supported version expansion marker"

$allTemplates = @()
foreach ($root in @($fabric, $baseDatapack, $baseNeoforge)) {
    $allTemplates += Get-TemplateNames $root
}

$templateReferences = New-Object System.Collections.Generic.List[object]
foreach ($file in Get-Files $fabric "*.definition.yaml") {
    $lines = Get-Content -LiteralPath $file.FullName
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*-?\s*template:\s*(\S+)') {
            $template = $Matches[1].Trim('"')
            if ($template -notmatch '^#') {
                $templateReferences.Add([pscustomobject]@{ File = $file.Name; Line = $i + 1; Template = $template })
            }
        }
    }
}
$missingTemplates = 0
foreach ($reference in $templateReferences) {
    $found = $false
    foreach ($candidate in $allTemplates) {
        if ($candidate -eq $reference.Template -or $candidate.EndsWith("/" + $reference.Template)) {
            $found = $true
            break
        }
    }
    if (-not $found) {
        $missingTemplates++
        Write-Host "FAIL  missing template reference $($reference.Template) in $($reference.File):$($reference.Line)" -ForegroundColor Red
    }
}
Check ($missingTemplates -eq 0) "all $($templateReferences.Count) definition template references resolve"

$utilRoots = @(
    (Join-Path $fabric "utils"),
    (Join-Path $baseDatapack "utils"),
    (Join-Path $baseNeoforge "utils")
)
$utilNames = @()
foreach ($utilRoot in $utilRoots) {
    if (Test-Path $utilRoot) {
        $utilNames += @(Get-ChildItem -LiteralPath $utilRoot -File | Select-Object -ExpandProperty Name)
    }
}

$missingIncludes = 0
foreach ($root in @($fabric, $baseDatapack, $baseNeoforge)) {
    foreach ($file in Get-Files $root "*.ftl") {
        $text = Get-Content -LiteralPath $file.FullName -Raw
        foreach ($match in [regex]::Matches($text, '<#(?:include|import)\s+"([^"$]+)"')) {
            $include = $match.Groups[1].Value.Replace('/', '\')
            $baseName = Split-Path $include -Leaf
            $directory = Split-Path $file.FullName -Parent
            $candidates = @(
                (Join-Path $directory $include),
                (Join-Path $root ("templates\" + $include)),
                (Join-Path $root ("utils\" + $include)),
                (Join-Path $root ("procedures\" + $include)),
                (Join-Path $root ("triggers\" + $include)),
                (Join-Path $root ("aitasks\" + $include)),
                (Join-Path $root ("cmdargs\" + $include)),
                (Join-Path $root $include)
            )
            foreach ($utilRoot in $utilRoots) {
                $candidates += (Join-Path $utilRoot $baseName)
            }

            $found = $false
            foreach ($candidate in $candidates) {
                try {
                    if (Test-Path -LiteralPath ([System.IO.Path]::GetFullPath($candidate)) -PathType Leaf) {
                        $found = $true
                        break
                    }
                } catch {
                    # An invalid candidate is simply not a match.
                }
            }
            if (-not $found) {
                $missingIncludes++
                Write-Host "FAIL  missing include '$($match.Groups[1].Value)' in $($file.FullName.Substring($resources.Length).TrimStart('\'))" -ForegroundColor Red
            }
        }
    }
}
Check ($missingIncludes -eq 0) "all literal template includes resolve"

$legacyTypes = @(Get-Files $fabric "*.ftl" | Select-String -Pattern 'types\[')
Check ($legacyTypes.Count -eq 0) 'no legacy types["..."] lookups remain in the main generator'

$pollution = @(Get-Files $fabric "*.ftl", "*.yaml", "*.json" |
    Select-String -Pattern 'net\.neoforged|@EventBusSubscriber|NeoForgeMod|IItemHandler|IFluidHandler')
Check ($pollution.Count -eq 0) "no NeoForge Java API references in the main generator"

$mixinJson = Get-Content -LiteralPath (Join-Path $fabric "templates\modbase\mixin.json.ftl") -Raw
Check ($mixinJson -match '"defaultRequire":\s*0') "mixin.json defaultRequire is 0"
Check ($mixinJson -match 'fragments\.mixin') "mixin.json merges generator fragments"
$accesswidener = Get-Content -LiteralPath (Join-Path $fabric "templates\modbase\accesswidener.ftl") -Raw
Check ($accesswidener -match 'fragments\.accesstransformer') "accesswidener.ftl merges access transformer fragments"

$definitionNames = @(
    "armor", "attribute", "block", "dimension", "feature", "fluid", "item",
    "itemextension", "livingentity", "particle", "plant", "projectile",
    "specialentity", "tool"
)
$missingBaseTypes = 0
foreach ($name in $definitionNames) {
    $file = Join-Path $fabric "$name.definition.yaml"
    $text = Get-Content -LiteralPath $file -Raw
    if ($text -notmatch '(?m)^base_types:') {
        $missingBaseTypes++
        Write-Host "FAIL  $name.definition.yaml has no base_types declaration" -ForegroundColor Red
    }
}
Check ($missingBaseTypes -eq 0) "all $($definitionNames.Count) element definitions declare base_types"

$loottable = Get-Content -LiteralPath (Join-Path $fabric "loottable.definition.yaml") -Raw
Check ($loottable -match 'lootTableToModify') "lootTableToModify is excluded for Fabric"
$blockDefinition = Get-Content -LiteralPath (Join-Path $fabric "block.definition.yaml") -Raw
Check ($blockDefinition -match 'strippingResult') "strippingResult is excluded because transformable is not ported"
$tabDefinition = Get-Content -LiteralPath (Join-Path $fabric "tab.definition.yaml") -Raw
Check ($tabDefinition -match 'CreativeModeTab\$Builder showTitle Z') "tab definition contributes the hide-title access transformer fragment"
$procedureDefinition = Get-Content -LiteralPath (Join-Path $fabric "procedure.definition.yaml") -Raw
Check ($procedureDefinition -match 'PiglinAi isBarterCurrency') "procedure definition contributes the piglin-currency access transformer fragment"
$piglinProcedure = Get-Content -LiteralPath (Join-Path $fabric "procedures\item_is_piglin_currency.java.ftl") -Raw
Check ($piglinProcedure -match 'PiglinAi\.isBarterCurrency') "piglin-currency procedure uses the vanilla helper"
Check ($piglinProcedure -notmatch 'ItemStack\.isPiglinCurrency|\.isPiglinCurrency\(\)') "piglin-currency procedure does not emit the NeoForge-only ItemStack method"
$itemDefinition = Get-Content -LiteralPath (Join-Path $fabric "item.definition.yaml") -Raw
Check ($itemDefinition -match 'field_exclusions:\s*\[isPiglinCurrency\]') "NeoForge-only item isPiglinCurrency field remains excluded"
$dimensionDefinition = Get-Content -LiteralPath (Join-Path $fabric "dimension.definition.yaml") -Raw
Check ($dimensionDefinition -match 'dimension_void\.json\.ftl') "void dimension template is registered"
Check (Test-Path (Join-Path $fabric "enchantmenteffects")) "enchantment effect templates are present in the main generator"

$newProcedures = @(
    "entity_attackcooldown", "entity_attackcooldown_reset", "entity_forceplayerattack",
    "entity_has_line_of_sight", "entity_invulnerabletime", "entity_set_invulnerabletime",
    "entity_is_moving", "item_can_be_hurt_by", "item_can_repair", "item_is_empty",
    "item_is_piglin_currency", "vector_dot", "world_data_get_emitted_strong_redstone_power"
)
$missingProcedures = 0
foreach ($name in $newProcedures) {
    if (-not (Test-Path (Join-Path $fabric "procedures\$name.java.ftl"))) {
        $missingProcedures++
        Write-Host "FAIL  missing procedure template $name.java.ftl" -ForegroundColor Red
    }
}
Check ($missingProcedures -eq 0) "all $($newProcedures.Count) new procedure templates exist"
Check (Test-Path (Join-Path $fabric "aitasks\attack_with_procedure.java.ftl")) "custom attack AI task template exists"
Check (Test-Path (Join-Path $fabric "triggers\player_useitem_finish.java.ftl")) "player_useitem_finish trigger template exists"
$livingEntityEvents = Get-Content -LiteralPath (Join-Path $fabric "templates\event\livingentity_events.java.ftl") -Raw
Check ($livingEntityEvents -match 'ENTITY_FINISH_USING_ITEM') "finish-use event is generated"
$livingEntityMixin = Get-Content -LiteralPath (Join-Path $fabric "templates\mixin\livingentity_mixin.java.ftl") -Raw
Check ($livingEntityMixin -match 'completeUsingItem') "completeUsingItem mixin is generated"

$blockInventoryTemplates = @(Get-ChildItem -LiteralPath (Join-Path $fabric "procedures") -File -Filter 'block_inv_*.java.ftl')
Check ($blockInventoryTemplates.Count -ge 13) "block inventory procedure templates exist ($($blockInventoryTemplates.Count))"
$entityNbtTemplates = @(Get-ChildItem -LiteralPath (Join-Path $fabric "procedures") -File -Filter 'entity_nbt_*.java.ftl')
Check ($entityNbtTemplates.Count -ge 8) "entity NBT procedure templates exist ($($entityNbtTemplates.Count))"
Check (Test-Path (Join-Path $fabric "templates\elementinits\entitynbt.java.ftl")) "entity NBT attachment helper template exists"
$generatorYamlText = Get-Content -LiteralPath (Join-Path $fabric "generator.yaml") -Raw
Check ($generatorYamlText -match 'elementinits/entitynbt\.java\.ftl') "generator.yaml registers the entity NBT helper"
$sufixTypos = @(Get-Files $fabric "*.yaml" | Select-String -Pattern 'sufix=')
Check ($sufixTypos.Count -eq 0) "armor model suffix variable uses the correct spelling"
$armorModels = Get-Content -LiteralPath (Join-Path $fabric "templates\elementinits\armormodels.java.ftl") -Raw
Check ($armorModels -match 'prepareCustomHeadPart') "custom armor head pose normalization is generated"
$armorClient = Get-Content -LiteralPath (Join-Path $fabric "templates\armor\armor_client.java.ftl") -Raw
Check ($armorClient -match 'prepareCustomHeadPart') "armor client applies the custom head pose normalization"
$equipmentMixin = Get-Content -LiteralPath (Join-Path $fabric "templates\armor\equipment_layer_mixin.java.ftl") -Raw
Check ($equipmentMixin -match 'getArmorTexture') "equipment layer mixin applies the custom armor model texture"

$gradleProperties = Get-Content -LiteralPath (Join-Path $pluginRoot "gradle.properties") -Raw
Check ($gradleProperties -match 'pluginVersion=2026\.3-1\.0\.3\.1-beta') "plugin version is 2026.3-1.0.3.1-beta"
$readme = Get-Content -LiteralPath (Join-Path $pluginRoot "README.md") -Raw
Check ($readme -match 'https://github\.com/user-attachments/assets/a210a188-8b5a-4e03-97b4-1754d6b0e59d') "README keeps the standard banner image link"
Check ($readme -match '# MCreator - Minecraft Mod Maker') "README keeps the MCreator footer heading"
Check ($readme.TrimEnd().EndsWith('NOT AN OFFICIAL MINECRAFT PRODUCT. NOT APPROVED BY OR ASSOCIATED WITH MOJANG OR MICROSOFT.')) "README keeps the standard MCreator footer"
Check (Test-Path (Join-Path $pluginRoot "tools\check-archive.ps1")) "archive check script exists"

$workspaceBuild = Get-Content -LiteralPath (Join-Path $fabric "workspacebase\build.gradle") -Raw
Check ($workspaceBuild -match 'fabric-loader:0\.20\.1') "workspacebase uses Fabric Loader 0.20.1"
$wrapper = Get-Content -LiteralPath (Join-Path $fabric "workspacebase\gradle\wrapper\gradle-wrapper.properties") -Raw
Check ($wrapper -match 'distributionUrl=https\\://services\.gradle\.org/distributions/gradle-9\.8\.0-bin\.zip') "workspacebase wrapper uses the public Gradle 9.8.0 URL"
Check ($wrapper -notmatch 'file\\?:///') "workspacebase wrapper contains no local file URL"

$localPathPattern = 'file\\?:///[A-Za-z]:|(^|[^A-Za-z])[A-Za-z]:\\|(^|[^A-Za-z])[A-Za-z]:/[A-Za-z]|/' + 'home' + '/|/' + 'Users' + '/|/' + 'mnt' + '/'
$auditFiles = @()
foreach ($pattern in @('*.properties', '*.gradle', '*.ftl', '*.yaml', '*.json', '*.md', '*.ps1', '*.java', '*.txt', '*.xml', '*.toml', 'gradlew', 'gradlew.bat')) {
    $auditFiles += Get-Files $pluginRoot $pattern
}
$auditFiles = @($auditFiles | Where-Object { $_.FullName -notmatch '\\build\\|\\.git\\' } | Sort-Object FullName -Unique)
$localPathHits = @($auditFiles | Select-String -Pattern $localPathPattern)
if ($localPathHits.Count -gt 0) {
    foreach ($hit in $localPathHits) {
        Write-Host "FAIL  local path in $($hit.Path):$($hit.LineNumber): $($hit.Line.Trim())" -ForegroundColor Red
    }
}
Check ($localPathHits.Count -eq 0) "no hardcoded local absolute paths or file URLs in source"

if (-not $SkipJavaParse) {
    $jdk = Join-Path $MCreatorRoot "jdk\bin"
    $libs = Join-Path $MCreatorRoot "lib\*"
    if ((Test-Path (Join-Path $jdk "javac.exe")) -and (Test-Path (Join-Path $MCreatorRoot "lib"))) {
        $buildDir = Join-Path $pluginRoot "build\tools\validate"
        New-Item -ItemType Directory -Force $buildDir | Out-Null
        foreach ($source in @("ValidateYaml.java", "ValidateFtl.java")) {
            & (Join-Path $jdk "javac.exe") -encoding UTF-8 -cp $libs -d $buildDir (Join-Path $PSScriptRoot "validate\$source")
            if ($LASTEXITCODE -ne 0) { throw "javac failed for $source" }
        }

        & (Join-Path $jdk "java.exe") -cp "$buildDir;$libs" ValidateYaml $resources
        Check ($LASTEXITCODE -eq 0) "all YAML files parse with MCreator's SnakeYAML Engine"

        $ftlRoots = @(
            (Join-Path $fabric "templates"),
            (Join-Path $fabric "utils"),
            (Join-Path $fabric "procedures"),
            (Join-Path $fabric "triggers"),
            (Join-Path $fabric "aitasks"),
            (Join-Path $fabric "cmdargs"),
            $fabric,
            (Join-Path $baseDatapack "templates"),
            (Join-Path $baseDatapack "utils"),
            (Join-Path $baseDatapack "enchantmenteffects"),
            $baseDatapack,
            (Join-Path $baseNeoforge "templates"),
            (Join-Path $baseNeoforge "utils"),
            (Join-Path $baseNeoforge "features"),
            $baseNeoforge
        )
        & (Join-Path $jdk "java.exe") -cp "$buildDir;$libs" ValidateFtl @ftlRoots
        Check ($LASTEXITCODE -eq 0) "all FreeMarker templates parse"
    } else {
        Write-Host "SKIP  Java YAML/FTL parse (MCreator JDK or lib directory not found at $MCreatorRoot)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Checks: $checks, failures: $($failures.Count)"
if ($failures.Count -gt 0) {
    exit 1
}
exit 0
