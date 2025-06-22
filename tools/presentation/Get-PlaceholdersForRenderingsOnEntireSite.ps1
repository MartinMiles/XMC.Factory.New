[CmdletBinding()]
param(
    [Parameter()]
    [string]$database = "old",

    [Parameter()]
    [string]$siteRoot = "/sitecore/content/Habitat"

)

Set-Location -Path $PSScriptRoot

# Load connection settings
$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json

# Import SPE and start a remote session
Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri `
                              -Username $config.username `
                              -SharedSecret $config.SPE_REMOTING_SECRET

Invoke-RemoteScript -Session $session -ScriptBlock {


# Configuration

$deviceName          = "Default"
$componentFieldId    = "{037FE404-DD19-4BF7-8E30-4DADF68B27B0}"
$jsonTemplateId      = "{5A4F1511-DC87-41F2-8B85-CAC25C30E08F}"

# Debugging
$debugRenderingId    = '' #"{A85A0B65-D3B7-48B8-B362-F17AA3CA7DF1}"
$debugPlaceholder    = '' #"col-narrow-2"

# 1) Mount master drive if needed
if (-not (Get-PSDrive -Name $using:database -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $using:database -PSProvider Sitecore -Root "/" -Database "$using:database" | Out-Null
}

# 2) Get databases & devices
$database = [Sitecore.Configuration.Factory]::GetDatabase("old")
$rootItem = $database.GetItem($using:siteRoot)
if (-not $rootItem) { throw "Site root not found." }

$device = $database.Resources.Devices.GetAll() | Where-Object { $_.Name -eq $deviceName }
if (-not $device) { throw "Device '$deviceName' not found." }

# 3) Build placeholder-key > definition-ID map
$fieldId    = [Sitecore.Data.ID]::Parse("{7256BDAB-1FD2-49DD-B205-CB4873D2917C}")  # Placeholder Key field
$templateId = [Sitecore.Data.ID]::Parse("{5C547D4E-7111-4995-95B0-6B561751BF2E}")  # Placeholder Settings template
$phSettingsRoot = $database.GetItem("/sitecore/layout/Placeholder Settings")
if (-not $phSettingsRoot) { throw "Placeholder Settings folder not found." }

$allPhSettings = @($phSettingsRoot.Axes.GetDescendants())
$placeholderMap = @{}
foreach ($ps in $allPhSettings) {
    if ($ps.TemplateID -eq $templateId) {
        $keyVal = $ps.Fields[$fieldId].Value
        if ($keyVal -and -not $placeholderMap.ContainsKey($keyVal)) {
            # store the item ID (includes braces)
            $placeholderMap[$keyVal] = $ps.ID.ToString()
        }
    }
}

# 4) Gather items with presentation
$itemsWithPresentation = $rootItem.Axes.GetDescendants() | Where-Object {
    $_["__Renderings"] -or ($_.__StandardValues -and $_.__StandardValues["__Renderings"])
}

# 5) Initialize caches & map
$renderingMap   = @{}
$renderingCache = @{}

foreach ($item in $itemsWithPresentation) {
    try {
        $renderings = $item.Visualization.GetRenderings($device, $true)
        if (-not $renderings) { continue }

        # collect all placeholder-paths on this page
        $placeholderPaths = $renderings |
            Where-Object { $_.Placeholder } |
            ForEach-Object { $_.Placeholder.TrimStart("/") }

        foreach ($ref in $renderings) {
            $rid = $ref.RenderingID.ToString()

            # a) Cache rendering metadata if missing
            if (-not $renderingCache.ContainsKey($rid)) {
                $rItem = $database.GetItem($ref.RenderingID)
                if (-not $rItem) { continue }

                # always pull the component-name field
                $comp = ""
                if ($rItem.Fields[$componentFieldId] -and $rItem.Fields[$componentFieldId].HasValue) {
                    $comp = $rItem.Fields[$componentFieldId].Value
                }

                $renderingCache[$rid] = @{
                    RenderingPath = $rItem.Paths.FullPath
                    ComponentName = $comp
                }
            }

            $meta   = $renderingCache[$rid]
            $prefix = $ref.Placeholder.TrimStart("/")

            # b) Determine declared placeholders (normalized)
            $declaredPlaceholders = $placeholderPaths |
                Where-Object { $_ -like "$prefix/*" } |
                ForEach-Object {
                    $rel = $_.Substring($prefix.Length + 1)
                    if ($rel -notmatch "/") { $rel } else { $rel.Split("/")[0] }
                } |
                Sort-Object -Unique |
                ForEach-Object {
                    # strip dynamic suffix e.g. section-{GUID}-0 > section
                    if ($_ -match '^(.+?)-\{[0-9A-Fa-f-]+\}-\d+$') { $matches[1] }
                    else { $_ }
                }

            # c) Ensure map entry
            if (-not $renderingMap.ContainsKey($rid)) {
                $renderingMap[$rid] = [ordered]@{
                    RenderingID   = $rid
                    ComponentName = $meta.ComponentName
                    RenderingPath = $meta.RenderingPath
                    Placeholders  = @()  # will become array of keys
                }
            }

            # d) Populate and debug
            foreach ($ph in $declaredPlaceholders) {
                if ($rid -eq $debugRenderingId -and $ph -eq $debugPlaceholder) {
                    $slotPath  = "$prefix/$ph"
                    $childRefs = $renderings | Where-Object {
                        $_.Placeholder.TrimStart("/") -eq $slotPath
                    }
                    foreach ($childRef in $childRefs) {
                        $childRid = $childRef.RenderingID.ToString()
                        # resolve child path
                        if (-not $renderingCache.ContainsKey($childRid)) {
                            $cItem = $database.GetItem($childRef.RenderingID)
                            $cPath = if ($cItem) { $cItem.Paths.FullPath } else { "[unknown]" }
                        } else {
                            $cPath = $renderingCache[$childRid].RenderingPath
                        }
                        Write-Output "Debug: about to add placeholder '$ph' for rendering $debugRenderingId on page ID $($item.ID) - $($item.Paths.FullPath); child rendering $childRid ($cPath)"
                    }
                }

                if (-not ($renderingMap[$rid].Placeholders -contains $ph)) {
                    $renderingMap[$rid].Placeholders += $ph
                }
            }
        }
    }
    catch {
        throw "Error on $($item.Paths.FullPath): $_"
    }
}

# 6) Convert placeholder-name arrays > pipe-separated definition IDs
foreach ($entry in $renderingMap.Values) {
    $ids = @()
    foreach ($key in $entry.Placeholders) {
        if ($placeholderMap.ContainsKey($key)) {
            $ids += $placeholderMap[$key]
        }
    }
    # replace the array with a string of GUIDs joined by '|'
    $entry.Placeholders = $ids -join "|"
}

# 7) Filter out empty placeholders and emit JSON
$filteredOutput = $renderingMap.Values | Where-Object { $_.Placeholders }

($filteredOutput | ConvertTo-Json -Depth 10) -replace "\s+", ""



}

# Tear down session
Stop-ScriptSession -Session $session
