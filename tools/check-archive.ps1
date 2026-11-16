param(
    [string]$Archive = ""
)

$ErrorActionPreference = "Stop"
$pluginRoot = Split-Path -Parent $PSScriptRoot
if (-not $Archive) {
    $Archive = Join-Path $pluginRoot "build\libs\generator-fabric-26.1.2.zip"
}

if (-not (Test-Path -LiteralPath $Archive)) {
    Write-Error "Archive not found: $Archive"
    exit 1
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archivePath = (Resolve-Path -LiteralPath $Archive).Path
$zip = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
try {
    $entries = @($zip.Entries | ForEach-Object { $_.FullName })
} finally {
    $zip.Dispose()
}
$topLevel = @($entries | ForEach-Object { ($_ -split '[\\/]')[0] } | Sort-Object -Unique)
$generatorYaml = @($entries | Where-Object { $_ -match '(^|[\\/])generator\.yaml$' })
$baseGeneratorYaml = @($entries | Where-Object { $_ -match '^fabric-26\.1\.2-base[\\/].*generator\.yaml$' })
$forbidden = @($entries | Where-Object { $_ -match '^(build|tools|\.gradle)[\\/]' })
$backslashEntries = @($entries | Where-Object { $_ -match '\\' })

$failures = 0
function Check([bool]$condition, [string]$message) {
    if ($condition) {
        Write-Host "OK    $message"
    } else {
        Write-Host "FAIL  $message" -ForegroundColor Red
        $script:failures++
    }
}

Check ($topLevel -contains "plugin.json") "archive contains plugin.json at the root"
Check ($topLevel -contains "LICENSE") "archive contains LICENSE at the root"
Check ($topLevel -contains "fabric-26.1.2") "archive contains the main generator"
Check ($topLevel -contains "fabric-26.1.2-base") "archive contains the embedded base layers"
Check ($generatorYaml.Count -eq 1) "archive contains exactly one generator.yaml"
Check ($baseGeneratorYaml.Count -eq 0) "embedded base layers contain no generator.yaml"
Check ($forbidden.Count -eq 0) "archive contains no build, tools or .gradle entries"
Check ($backslashEntries.Count -eq 0) "archive entry paths use forward-slash separators"

$item = Get-Item -LiteralPath $Archive
$hash = (Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash
Write-Host ""
Write-Host "Archive: $($item.FullName)"
Write-Host "Size: $($item.Length) bytes"
Write-Host "SHA-256: $hash"
Write-Host "Top-level entries: $($topLevel -join ', ')"
Write-Host "Failures: $failures"
if ($failures -gt 0) {
    exit 1
}
exit 0
