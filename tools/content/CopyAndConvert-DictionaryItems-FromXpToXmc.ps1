###
#   Usage:
###
param(
    [string]$SourceDatabase = "old",
    [string]$SourcePath = "/sitecore/content/Habitat/Global/Dictionary",
    [string]$TargetDatabase = "master",
    [string]$TargetPath = "/sitecore/content/Zont/Habitat/Dictionary"
)

Set-Location -Path $PSScriptRoot
$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json
Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri -Username $config.username -SharedSecret $config.SPE_REMOTING_SECRET
Invoke-RemoteScript -Session $session -ScriptBlock {


$srcFolderTemplate = "{98E4BDC6-9B43-4EB2-BAA3-D4303C35852E}"
$srcEntryTemplate = "{EC4DD3F2-590D-404B-9189-2A12679749CC}"
$srcPhraseField = "{DDACDD55-5B08-405F-9E58-04F09AED640A}"

$trgFolderTemplate = "{267D9AC7-5D85-4E9D-AF89-99AB296CC218}"
$trgEntryTemplate = "{6D1CD897-1936-4A3A-A511-289A94C2A7B1}"
$trgKeyField = "{580C75A8-C01A-4580-83CB-987776CEB3AF}"
$trgPhraseField = "{2BA3454A-9A9C-4CDF-A9F8-107FD484EB6E}"

function Copy-DictionaryItemsRecursive {
    param(
        [Sitecore.Data.Items.Item]$SrcParent,
        [Sitecore.Data.Items.Item]$TrgParent,
        [Sitecore.Data.Database]$SrcDB,
        [Sitecore.Data.Database]$TrgDB,
        [int]$Depth = 0
    )

    $indent = (" " * ($Depth * 2))
    $children = $SrcParent.GetChildren()
    Write-Output "$indent- Processing source: $($SrcParent.Paths.FullPath) | Child count: $($children.Count)"

    foreach ($child in $children) {
        Write-Output "$indent  - Processing child: $($child.Paths.FullPath) | TemplateID: $($child.TemplateID) | Name: $($child.Name)"
        $templateId = $child.TemplateID.ToString()
        $newItemName = $child.Name
        $newItem = $null

        try {
            # Check if this item already exists by name under TrgParent
            $existingByName = $TrgParent.Children | Where-Object { $_.Name -eq $newItemName }
            if ($existingByName) {
                Write-Output "$indent    - Using existing target item (by name): $($existingByName.Paths.FullPath)"
                $newItem = $existingByName
            } else {
                # Prepare template item
                $templateItem = $null
                if ($templateId -eq $srcFolderTemplate) {
                    $templateItem = $TrgDB.GetTemplate($trgFolderTemplate)
                    Write-Output "$indent    - Using target template (folder): $($templateItem -ne $null)"
                } elseif ($templateId -eq $srcEntryTemplate) {
                    $templateItem = $TrgDB.GetTemplate($trgEntryTemplate)
                    Write-Output "$indent    - Using target template (entry): $($templateItem -ne $null)"
                }
                if (-not $templateItem) { throw "$indent    - ERROR: Target template not found for $newItemName" }

                # Attempt to create under the current TrgParent
                Write-Output "$indent    - Attempting to Add '$newItemName' under $($TrgParent.Paths.FullPath)"
                $newItem = $TrgParent.Add($newItemName, $templateItem)
                if (-not $newItem) { throw "$indent    - ERROR: Failed to add item $newItemName under $($TrgParent.Paths.FullPath)" }
                Write-Output "$indent    - Created item: $($newItem.Paths.FullPath) [ID: $($newItem.ID)]"
            }

            # Recurse or fill entry fields
            if ($templateId -eq $srcFolderTemplate) {
                Write-Output "$indent    - Recursing into folder: $($child.Paths.FullPath)"
                Copy-DictionaryItemsRecursive -SrcParent $child -TrgParent $newItem -SrcDB $SrcDB -TrgDB $TrgDB -Depth ($Depth + 1)
            } elseif ($templateId -eq $srcEntryTemplate) {
                foreach ($lang in $child.Languages) {
                    $srcItemLang = $SrcDB.GetItem($child.ID, $lang)
                    if (-not $srcItemLang) { throw "$indent    - ERROR: Source item language $lang missing for $($child.Paths.FullPath)" }
                    $trgItemLang = $TrgDB.GetItem($newItem.ID, $lang)
                    if (-not $trgItemLang) {
                        $trgItemLang = $newItem.Versions.AddVersion($lang)
                        if (-not $trgItemLang) { throw "$indent    - ERROR: Failed to add language version $lang to $($newItem.Paths.FullPath)" }
                    }
                    $phraseValue = $srcItemLang.Fields[$srcPhraseField].Value
                    $trgItemLang.Editing.BeginEdit()
                    $trgItemLang.Fields[$trgKeyField].Value = $newItemName
                    $trgItemLang.Fields[$trgPhraseField].Value = $phraseValue
                    $trgItemLang.Editing.EndEdit()
                    Write-Output "$indent    - Populated entry ($lang): $($newItem.Paths.FullPath) [ID: $($newItem.ID)]"
                }
            } else {
                Write-Output "$indent    - Skipping unsupported template: $($child.Name) [$templateId]"
            }
        } catch {
            Write-Output "$indent    - ERROR: $($_.Exception.Message) at item $($child.Paths.FullPath)"
            throw
        }
    }
}

try {
    $srcDB = Get-Database $Using:SourceDatabase
    $trgDB = Get-Database $Using:TargetDatabase
    $srcParent = $srcDB.GetItem($Using:SourcePath)
    $trgParent = $trgDB.GetItem($Using:TargetPath)
    Write-Output "Start: Copying dictionary items from $Using:SourcePath [$Using:SourceDatabase] to $Using:TargetPath [$Using:TargetDatabase] ..."
    if (-not $srcParent) { throw "Source parent item not found: $Using:SourcePath in DB: $Using:SourceDatabase" }
    if (-not $trgParent) { throw "Target parent item not found: $Using:TargetPath in DB: $Using:TargetDatabase" }

    Copy-DictionaryItemsRecursive -SrcParent $srcParent -TrgParent $trgParent -SrcDB $srcDB -TrgDB $trgDB -Depth 0
    Write-Output "Dictionary copy completed successfully."
} catch {
    Write-Output "SCRIPT ERROR: $($_.Exception.Message)"
    exit 1
}





}
Stop-ScriptSession -Session $session