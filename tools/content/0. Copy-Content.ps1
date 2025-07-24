
param(
    [string]$sourceDb     = "old",
    [string]$targetDb     = "master"
)

$scriptsToCall = @(
    "0.1. Copy-Templates.ps1",
    "0.2. Copy-Content.ps1",
    "0.3. Copy-Placeholders.ps1",
    "0.4. Copy-Media.ps1"
)

Write-Host "Identifying items to copy..."
# Start-Sleep -Seconds 1

foreach ($scriptName in $scriptsToCall) {
    $fullPath = Join-Path $PSScriptRoot $scriptName

    if (-not (Test-Path $fullPath)) {
        Write-Warning "Script not found: $scriptName. Skipping."
        continue
    }

    # Write-Host "`nRunning: $scriptName"
    try {
         & $fullPath -sourceDb $sourceDb -targetDb $targetDb
    } catch {
        Write-Error "Script $scriptName failed: $_"
    }
}
