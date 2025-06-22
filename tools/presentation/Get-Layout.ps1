# Once we have a page to process at destination, we can get its layout.

param(
    [string]$itemPath = "/sitecore/content/Zont/Habitat/Home/target"
)

Set-Location -Path $PSScriptRoot

$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json
# Write-Output "ConnectionUri: $($config.connectionUri)"
# Write-Output "Username     : $($config.username)"
# Write-Output "SPE Remoting Secret : $($config.SPE_REMOTING_SECRET)"

# Write-Output "Get item fields of '$itemPath'..."
Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri -Username $config.username -SharedSecret $config.SPE_REMOTING_SECRET
Invoke-RemoteScript -Session $session -ScriptBlock {


# -----------------------------------------------
# Script: Export-PageLayoutHierarchyAsJson-Final-Minified.ps1
# Purpose: Produce nested JSON for �/sitecore/content/Zont/Habitat/Home/AAA�,
#          with "uid" first, then "placeholders", and output minified JSON.
# -----------------------------------------------

# 1. MOUNT MASTER: PSDrive IF NOT ALREADY PRESENT
if (-not (Get-PSDrive -Name master -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name master -PSProvider Sitecore -Root "/" -Database "master" -ErrorAction Stop | Out-Null
}

# 2. GET MASTER DB & PAGE ITEM
$database = [Sitecore.Configuration.Factory]::GetDatabase("master")
if (-not $database) { return }
$pageItem = $database.GetItem($Using:itemPath)
if (-not $pageItem) { return }

# 3. IDENTIFY �DEFAULT� DEVICE (or fallback)
$allDevices = $database.Resources.Devices.GetAll()
if (-not $allDevices) { return }
$deviceItem = $allDevices | Where-Object { $_.Name -eq "Default" }
if (-not $deviceItem) { $deviceItem = $allDevices[0] }

# 4. GET ALL RENDERING REFERENCES (incl. inherited standard-values)
$renderingRefs = $pageItem.Visualization.GetRenderings($deviceItem, $true)
if (-not $renderingRefs) {
    $emptyTree = @{
        UID          = $pageItem.ID.ToGuid().ToString("D")
        placeholders = @()
    }
    ($emptyTree | ConvertTo-Json -Depth 5) -replace "\s+", ""
    return
}

# 5. COLLECT UNIQUE PLACEHOLDER PATHS (no leading slash)
$allPlaceholderPaths = $renderingRefs |
    Where-Object { $_.Placeholder } |
    ForEach-Object { $_.Placeholder.TrimStart("/") } |
    Sort-Object -Unique

# 6. HELPER: Build placeholder object
function Build-PlaceholderObject {
    param(
        [string]$placeholderPath,
        [Sitecore.Layouts.RenderingReference[]]$allRefs
    )
    $refsHere = $allRefs | Where-Object { $_.Placeholder.TrimStart("/") -ieq $placeholderPath }
    $renderingNodes = @()
    foreach ($ref in $refsHere) {
        $renderingNodes += Build-RenderingObject -ref $ref -allPaths $allPlaceholderPaths -allRefs $allRefs
    }
    return @{
        placeholder  = $placeholderPath
        renderings   = $renderingNodes
    }
}

# 7. HELPER: Build rendering object (uid first, then placeholders)
function Build-RenderingObject {
    param(
        [Sitecore.Layouts.RenderingReference]$ref,
        [string[]]$allPaths,
        [Sitecore.Layouts.RenderingReference[]]$allRefs
    )
    $renderingNode = [ordered]@{ uid = $ref.UniqueId.ToString() }
    $ph = $ref.Placeholder.TrimStart("/")
    $childKeys = @()
    foreach ($candidate in $allPaths) {
        if ($candidate -like "$ph/*") {
            $relative = $candidate.Substring($ph.Length + 1)
            $segment  = $relative.Split("/")[0]
            $childKey = "$ph/$segment"
            if (-not ($childKeys -contains $childKey)) { $childKeys += $childKey }
        }
    }
    if ($childKeys.Count -gt 0) {
        $childPlaceholderObjects = @()
        foreach ($child in $childKeys) {
            $childPlaceholderObjects += Build-PlaceholderObject -placeholderPath $child -allRefs $allRefs
        }
        $renderingNode["placeholders"] = $childPlaceholderObjects
    } else {
        $renderingNode["placeholders"] = @()
    }
    return $renderingNode
}

# 8. TOP-LEVEL PLACEHOLDER KEYS (no "/")
$topLevelKeys = $allPlaceholderPaths | Where-Object { $_ -notlike "*/?*" }

# 9. BUILD TREE
$placeholderArray = @()
foreach ($top in $topLevelKeys) {
    $placeholderArray += Build-PlaceholderObject -placeholderPath $top -allRefs $renderingRefs
}

# 10. WRAP WITH ROOT UID
$result = [ordered]@{
    UID          = $pageItem.ID.ToGuid().ToString("D")
    placeholders = $placeholderArray
}

# 11. OUTPUT MINIFIED JSON
($result | ConvertTo-Json -Depth 10) -replace "\s+", ""



}
Stop-ScriptSession -Session $session