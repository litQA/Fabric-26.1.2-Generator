param(
    [string]$OutputDirectory = ""
)

$ErrorActionPreference = "Stop"

$pluginRoot = Split-Path -Parent $PSScriptRoot
$resources = Join-Path $pluginRoot "src\main\resources"
$properties = @{}
foreach ($line in Get-Content -LiteralPath (Join-Path $pluginRoot "gradle.properties")) {
    if ($line -match '^([^#=]+)=(.+)$') {
        $properties[$Matches[1].Trim()] = $Matches[2].Trim()
    }
}

$mcVersion = $properties["mcVersion"]
$pluginVersion = $properties["pluginVersion"]
$mcreatorVersion = $properties["mcreatorVersion"]
$parts = $mcreatorVersion.Split(".")
$supportedVersion = $parts[0] + $parts[1].PadLeft(3, "0")
if ($parts.Length -gt 2) {
    $supportedVersion += $parts[2]
}

if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $pluginRoot "build\libs"
}
New-Item -ItemType Directory -Force $OutputDirectory | Out-Null

$stage = Join-Path $pluginRoot "build\plugin-root"
if (Test-Path $stage) {
    Remove-Item -LiteralPath $stage -Recurse -Force
}
New-Item -ItemType Directory -Force $stage | Out-Null

$pluginJson = Get-Content -LiteralPath (Join-Path $resources "plugin.json") -Raw
$pluginJson = $pluginJson.Replace('${mcVersion}', $mcVersion)
$pluginJson = $pluginJson.Replace('${pluginVersion}', $pluginVersion)
$pluginJson = $pluginJson.Replace('${mcreatorVersion}', $mcreatorVersion)
$pluginJson = $pluginJson.Replace('${supportedVersion}', $supportedVersion)
Set-Content -LiteralPath (Join-Path $stage "plugin.json") -Value $pluginJson -NoNewline -Encoding utf8

Copy-Item -LiteralPath (Join-Path $resources "LICENSE") -Destination (Join-Path $stage "LICENSE") -Force
Copy-Item -LiteralPath (Join-Path $resources "help") -Destination (Join-Path $stage "help") -Recurse -Force
Copy-Item -LiteralPath (Join-Path $resources "fabric-26.1.2") -Destination (Join-Path $stage "fabric-26.1.2") -Recurse -Force
Copy-Item -LiteralPath (Join-Path $resources "fabric-26.1.2-base") -Destination (Join-Path $stage "fabric-26.1.2-base") -Recurse -Force

$zip = Join-Path $OutputDirectory "generator-fabric-26.1.2.zip"
if (Test-Path $zip) {
    Remove-Item -LiteralPath $zip -Force
}

# Build entries explicitly so ZIP paths always use forward slashes, as required
# by the ZIP specification and by MCreator's plugin loader.
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipStream = [System.IO.File]::Open($zip, [System.IO.FileMode]::Create)
try {
    $archive = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in Get-ChildItem -LiteralPath $stage -Recurse -File) {
            $relative = $file.FullName.Substring($stage.Length).TrimStart([char[]]@('\', '/')).Replace('\', '/')
            $entry = $archive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
            $entryStream = $entry.Open()
            try {
                $input = [System.IO.File]::OpenRead($file.FullName)
                try {
                    $input.CopyTo($entryStream)
                } finally {
                    $input.Dispose()
                }
            } finally {
                $entryStream.Dispose()
            }
        }
    } finally {
        $archive.Dispose()
    }
} finally {
    $zipStream.Dispose()
}

$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
$size = (Get-Item -LiteralPath $zip).Length
Write-Host "Plugin archive: $zip"
Write-Host "Size: $size bytes"
Write-Host "SHA-256: $hash"
Write-Host "Supported MCreator versions: $supportedVersion .. 202600399999"
