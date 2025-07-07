param(
    [string]$PageItemPath = "/sitecore/content/Zont/Habitat/Home/target"
)

Set-Location -Path $PSScriptRoot

$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json

Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri -Username $config.username -SharedSecret $config.SPE_REMOTING_SECRET
Invoke-RemoteScript -Session $session -ScriptBlock {

# -----------------------------------------------------------
# Inline Script for Sitecore PowerShell ISE:
# Replace Multiple Placeholders for Renderings
# Target Item: Default is /sitecore/content/Zont/Habitat/Home/AAA
# DB: master
# - Processes Standard Values, Shared Layout, and Final Layout.
# - Replaces three placeholder pairs:
#     $OldPlaceholder1 > $NewPlaceholder1
#     $OldPlaceholder2 > $NewPlaceholder2
#     $OldPlaceholder3 > $NewPlaceholder3
# - Removes leading slash for any top-level placeholder (single segment).
# - Logs every change to the console.
# -----------------------------------------------------------
    [string] $OldPlaceholder1    = "page-layout"
    [string] $NewPlaceholder1    = "headless-main"
    [string] $OldPlaceholder2    = "header-top"
    [string] $NewPlaceholder2    = "headless-header"
    [string] $OldPlaceholder3    = "footer"
    [string] $NewPlaceholder3    = "headless-footer"


# 1) Ensure master: PSDrive is mounted
if (-not (Get-PSDrive -Name master -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name master -PSProvider Sitecore -Root "/" -Database "master" -ErrorAction Stop | Out-Null
}

# 2) Get the master database and the page item
$db = [Sitecore.Configuration.Factory]::GetDatabase("master")
$item = $db.GetItem($Using:PageItemPath)
if ($null -eq $item) {
    Write-Error "Item not found at path: $(Using:PageItemPath)"
    return
}

# 3) Prepare an ArrayList for logging
$script:logEntries = New-Object System.Collections.ArrayList

# 4) Function to replace placeholders in a raw layout XML
function Replace-PlaceholdersInLayout {
    param(
        [string] $layoutXml,
        [string] $contextItemID,
        [string] $contextName,
        [string] $languageName
    )

    $layoutDef = [Sitecore.Layouts.LayoutDefinition]::Parse($layoutXml)
    $changed   = $false

    # Build mapping array from parameters
    $mappings = @(
        @{ Old = $OldPlaceholder1; New = $NewPlaceholder1 },
        @{ Old = $OldPlaceholder2; New = $NewPlaceholder2 },
        @{ Old = $OldPlaceholder3; New = $NewPlaceholder3 }
    )

    foreach ($devDef in $layoutDef.Devices) {
        $deviceName = $devDef.Name

        foreach ($rendDef in $devDef.Renderings) {
            $oldPlaceholder = $rendDef.Placeholder
            if ([string]::IsNullOrEmpty($oldPlaceholder)) { continue }

            $newPlaceholder = $null

            # 4a) Explicit mappings
            foreach ($mapping in $mappings) {
                $old = $mapping.Old
                $new = $mapping.New

                # Top-level exact match (with or without leading slash)
                if ($oldPlaceholder -eq $old -or $oldPlaceholder -eq "/$old") {
                    $newPlaceholder = $new
                    break
                }
                # Nested mapping: /old/suffix > /new/suffix
                $prefix = "/$old/"
                if ($oldPlaceholder.StartsWith($prefix)) {
                    $suffix         = $oldPlaceholder.Substring($prefix.Length)
                    $newPlaceholder = "/$new/$suffix"
                    break
                }
            }

            # 4b) Remove leading slash for other single-segment placeholders
            if (-not $newPlaceholder) {
                if ($oldPlaceholder -match '^/[^/]+$') {
                    $newPlaceholder = $oldPlaceholder.TrimStart('/')
                }
            }

            # 4c) Apply change if needed
            if ($newPlaceholder -and $newPlaceholder -ne $oldPlaceholder) {
                $rendDef.Placeholder = $newPlaceholder
                $changed             = $true

                $entry = [PSCustomObject]@{
                    ItemID         = $contextItemID
                    Context        = $contextName
                    Language       = $languageName
                    Device         = $deviceName
                    RenderingID    = $rendDef.RenderingID
                    OldPlaceholder = $oldPlaceholder
                    NewPlaceholder = $newPlaceholder
                }
                $null = $script:logEntries.Add($entry)
            }
        }
    }

    if ($changed) { return $layoutDef.ToXml() }
    return $null
}

# 5) Update Standard Values of the template
$templateItem = $db.GetItem($item.TemplateID.ToString())
if (-not $templateItem) {
    Write-Error "Unable to find template item for ID: $($item.TemplateID)"
    return
}

$stdValuesItem = $templateItem.Children | Where-Object { $_.Name -eq "__Standard Values" }
if (-not $stdValuesItem) {
    Write-Error "No __Standard Values found under template: $($templateItem.Paths.FullPath)"
} else {
    # Shared Layout
    $stdSharedField = $stdValuesItem.Fields["__Renderings"]
    if ($stdSharedField -and -not [string]::IsNullOrWhiteSpace($stdSharedField.Value)) {
        $newXml = Replace-PlaceholdersInLayout `
            -layoutXml     $stdSharedField.Value `
            -contextItemID $stdValuesItem.ID.ToString() `
            -contextName   "Standard Values Shared Layout" `
            -languageName  ""
        if ($newXml) {
            $stdValuesItem.Editing.BeginEdit()
            try {
                $stdSharedField.Value = $newXml
                Write-Output "? Standard Values (Shared Layout) updated on template: $($templateItem.Name)" 
            } finally {
                $stdValuesItem.Editing.EndEdit()
            }
        } else {
            Write-Output "?? No changes needed in Standard Values Shared Layout."
        }
    }
    # Final Layout
    $stdFinalField = $stdValuesItem.Fields["__Final Renderings"]
    if ($stdFinalField -and -not [string]::IsNullOrWhiteSpace($stdFinalField.Value)) {
        $newXml = Replace-PlaceholdersInLayout `
            -layoutXml     $stdFinalField.Value `
            -contextItemID $stdValuesItem.ID.ToString() `
            -contextName   "Standard Values Final Layout" `
            -languageName  ""
        if ($newXml) {
            $stdValuesItem.Editing.BeginEdit()
            try { 
                $stdFinalField.Value = $newXml 
                Write-Output "? Standard Values (Final Layout) updated on template: $($templateItem.Name)" 
            } finally { 
                $stdValuesItem.Editing.EndEdit() 
            }
        } else {
            Write-Output "?? No changes needed in Standard Values Final Layout."
        }
    }
}

# 6) Iterate through all languages of the page item
foreach ($lang in $item.Languages) {
    $langName       = $lang.Name
    $versionedItem  = $db.GetItem($Using:PageItemPath, $lang)
    if (-not $versionedItem) {
        Write-Output "?? Item not in language: $langName. Skipping."
        continue
    }

    # Shared Layout
    $sharedField = $versionedItem.Fields["__Renderings"]
    if ($sharedField -and -not [string]::IsNullOrWhiteSpace($sharedField.Value)) {
        $newXml = Replace-PlaceholdersInLayout `
            -layoutXml     $sharedField.Value `
            -contextItemID $versionedItem.ID.ToString() `
            -contextName   "Shared Layout" `
            -languageName  $langName
        if ($newXml) {
            $versionedItem.Editing.BeginEdit()
            try { 
                $sharedField.Value = $newXml 
                Write-Output "? [$langName] Shared Layout updated on: $($versionedItem.Paths.FullPath)" 
            } finally { 
                $versionedItem.Editing.EndEdit() 
            }
        } else {
            Write-Output "?? [$langName] No changes in Shared Layout."
        }
    }
    # Final Layout
    $finalField = $versionedItem.Fields["__Final Renderings"]
    if ($finalField -and -not [string]::IsNullOrWhiteSpace($finalField.Value)) {
        $newXml = Replace-PlaceholdersInLayout `
            -layoutXml     $finalField.Value `
            -contextItemID $versionedItem.ID.ToString() `
            -contextName   "Final Layout" `
            -languageName  $langName
        if ($newXml) {
            $versionedItem.Editing.BeginEdit()
            try { 
                $finalField.Value = $newXml 
                Write-Output "? [$langName] Final Layout updated on: $($versionedItem.Paths.FullPath)" 
            } finally { 
                $versionedItem.Editing.EndEdit() 
            }
        } else {
            Write-Output "?? [$langName] No changes in Final Layout."
        }
    }
}

# 7) Output log
if ($script:logEntries.Count -gt 0) {
    Write-Output "`n========== Placeholder Replacement Log ==========`n"
    $script:logEntries |
        Sort-Object Context, Language, Device |
        Format-Table `
            @{Label="Item ID";        Expression={$_.ItemID}},`
            @{Label="Context";        Expression={$_.Context}},`
            @{Label="Language";       Expression={$_.Language}},`
            @{Label="Device";         Expression={$_.Device}},`
            @{Label="Rendering ID";   Expression={$_.RenderingID}},`
            @{Label="Old Placeholder";Expression={$_.OldPlaceholder}},`
            @{Label="New Placeholder";Expression={$_.NewPlaceholder}}`
        -AutoSize

    Write-Output "`nTotal changes: $($script:logEntries.Count)`n"
} else {
    Write-Output "`n? No matching placeholders found. No changes made.`n"
}



}
Stop-ScriptSession -Session $session