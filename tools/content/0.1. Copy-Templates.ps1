###
#   Format: "recursice=/soure/database/path=/target/database/path"
###
param(
    [string[]]$PathMap = @(
        "true=/sitecore/templates/Project/Common=/sitecore/templates/Project/Zont/Common",
        "true=/sitecore/templates/Project/Habitat=/sitecore/templates/Project/Zont/Habitat",

        "true=/sitecore/templates/Feature/Accounts=/sitecore/templates/Feature/Zont/Habitat/Accounts",
        "true=/sitecore/templates/Feature/Demo=/sitecore/templates/Feature/Zont/Habitat/Demo",
        "true=/sitecore/templates/Feature/FAQ=/sitecore/templates/Feature/Zont/Habitat/FAQ",
        "true=/sitecore/templates/Feature/Identity=/sitecore/templates/Feature/Zont/Habitat/Identity",
        "true=/sitecore/templates/Feature/Language=/sitecore/templates/Feature/Zont/Habitat/Language",
        "true=/sitecore/templates/Feature/Maps=/sitecore/templates/Feature/Zont/Habitat/Maps",
        "true=/sitecore/templates/Feature/Media=/sitecore/templates/Feature/Zont/Habitat/Media",
        "true=/sitecore/templates/Feature/Metadata=/sitecore/templates/Feature/Zont/Habitat/Metadata",
        "true=/sitecore/templates/Feature/Multisite=/sitecore/templates/Feature/Zont/Habitat/Multisite",
        "true=/sitecore/templates/Feature/Navigation=/sitecore/templates/Feature/Zont/Habitat/Navigation",
        "true=/sitecore/templates/Feature/News=/sitecore/templates/Feature/Zont/Habitat/News",
        "true=/sitecore/templates/Feature/PageContent=/sitecore/templates/Feature/Zont/Habitat/",
        "true=/sitecore/templates/Feature/Person=/sitecore/templates/Feature/Zont/Habitat/Person",
        "true=/sitecore/templates/Feature/Search=/sitecore/templates/Feature/Zont/Habitat/Search",
        "true=/sitecore/templates/Feature/Social=/sitecore/templates/Feature/Zont/Habitat/Social",
        "true=/sitecore/templates/Feature/Teasers=/sitecore/templates/Feature/Zont/Habitat/Teasers",

        "true=/sitecore/templates/Foundation/Assets=/sitecore/templates/Foundation/Zont/Habitat/Assets",
        "true=/sitecore/templates/Foundation/Dictionary=/sitecore/templates/Foundation/Zont/Habitat/Dictionary",
        "true=/sitecore/templates/Foundation/FieldEditor=/sitecore/templates/Foundation/Zont/Habitat/FieldEditor",
        "true=/sitecore/templates/Foundation/Indexing=/sitecore/templates/Foundation/Zont/Habitat/Indexing",
        "true=/sitecore/templates/Foundation/LocalDatasource=/sitecore/templates/Foundation/Zont/Habitat/LocalDatasource",
        "true=/sitecore/templates/Foundation/Multisite=/sitecore/templates/Foundation/Zont/Habitat/Multisite",
        "true=/sitecore/templates/Foundation/Theming=/sitecore/templates/Foundation/Zont/Habitat/Theming",
        "true=/sitecore/templates/Foundation/SitecoreExtensions=/sitecore/templates/Foundation/Zont/Habitat/SitecoreExtensions",

        "true=/sitecore/templates/Branches/Foundation/Multisite=/sitecore/templates/Branches/Foundation/Zont/Habitat"
    ),
    [string]$sourceDb     = "old",
    [string]$targetDb     = "master"
)

Write-Output "`nCopying TEMPLATES...`n"

Set-Location -Path $PSScriptRoot
$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json
Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri -Username $config.username -SharedSecret $config.SPE_REMOTING_SECRET
Invoke-RemoteScript -Session $session -ScriptBlock {

    function Test-ParentPathsExist {
        param(
            [string]$fullPath,
            [Sitecore.Data.Database]$db
        )
        $segments = $fullPath.Trim('/').Split('/')
        $currentPath = ""
        foreach ($seg in $segments[0..($segments.Length - 2)]) {
            $currentPath = "$currentPath/$seg"
            if (-not ($db.GetItem($currentPath))) {
                return $currentPath
            }
        }
        return $null
    }

    function Copy-ItemWithOriginalId {
        param(
            [Sitecore.Data.Items.Item]$srcItem,
            [Sitecore.Data.Items.Item]$destParent,
            [Sitecore.Data.Database]$destDb,
            [bool]$recursive,
            [ref]$resultList
        )
        if (-not $destParent) { return $null }

        $existing = $destDb.GetItem("$($destParent.Paths.FullPath)/$($srcItem.Name)")
        $wasOverwritten = $false
        if ($existing) {
            $existing.Delete()
            $wasOverwritten = $true
        }
        $templateId = $srcItem.TemplateID
        $itemName   = $srcItem.Name
        $newItem = [Sitecore.Data.Managers.ItemManager]::AddFromTemplate(
            $itemName,
            $templateId,
            $destParent,
            $srcItem.ID
        )
        if (-not $newItem) { return $null }
        foreach ($lang in $srcItem.Languages) {
            $langItem = $srcItem.Database.GetItem($srcItem.ID, $lang)
            $verNums = $langItem.Versions.GetVersionNumbers()
            foreach ($ver in $verNums) {
                $srcVer = $srcItem.Database.GetItem($srcItem.ID, $lang, $ver)
                $destVer = $destDb.GetItem($newItem.ID, $lang, $ver)
                if (-not $destVer) {
                    $destVer = $newItem.Versions.AddVersion($lang)
                }
                if ($destVer -and $srcVer) {
                    $destVer.Editing.BeginEdit()
                    foreach ($field in $srcVer.Fields) {
                        if (-not $field.Shared) {
                            $destVer[$field.ID] = $srcVer[$field.ID]
                        }
                    }
                    $destVer.Editing.EndEdit()
                }
            }
        }
        $newItem.Editing.BeginEdit()
        foreach ($field in $srcItem.Fields) {
            if ($field.Shared) {
                $newItem[$field.ID] = $field.Value
            }
        }
        $newItem.Editing.EndEdit()
        $workflowFields = @("__Workflow", "__Workflow State", "__Lock", "__Workflow Comment")
        foreach ($wf in $workflowFields) {
            if ($srcItem.Fields[$wf]) {
                $newItem.Editing.BeginEdit()
                $newItem[$wf] = $srcItem[$wf]
                $newItem.Editing.EndEdit()
            }
        }
        $newItem.Security.SetAccessRules($srcItem.Security.GetAccessRules())
        # Collect result info
        $resultList.Value += ,@([PSCustomObject]@{
            Path = $newItem.Paths.FullPath
            Id = $newItem.ID.Guid
            WasOverwritten = $wasOverwritten
        })
        # Recurse if requested
        if ($recursive) {
            foreach ($child in $srcItem.GetChildren()) {
                Copy-ItemWithOriginalId -srcItem $child -destParent $newItem -destDb $destDb -recursive $true -resultList $resultList
            }
        }
        return $newItem
    }

    # MAIN LOGIC
    $srcDb = Get-Database $Using:sourceDb
    $destDb = Get-Database $Using:targetDb

    foreach ($mapping in $Using:PathMap) {
        $split = $mapping -split "=", 3
        if ($split.Length -ne 3) {
            Write-Output "Invalid mapping: $mapping. Use format: 'recursive=/source=/target'"
            Write-Output ""
            break
        }
        $recursiveFlag = $split[0].ToLower() -eq "true"
        $sourcePath = $split[1]
        $targetPath = $split[2]

        $srcItem = $srcDb.GetItem($sourcePath)
        if (-not $srcItem) {
            Write-Output "Source item '$sourcePath' not found in database '$Using:sourceDb'. Skipping."
            Write-Output ""
            break
        }

        $missingParent = Test-ParentPathsExist -fullPath $targetPath -db $destDb
        if ($missingParent) {
            Write-Output "ERROR: Parent item '$missingParent' does not exist in target database '$Using:targetDb' for mapping:"
            Write-Output "       $mapping"
            Write-Output ""
            break
        }

        $destSegments = $targetPath.Trim('/').Split('/')
        $destParentPath = "/" + ($destSegments[0..($destSegments.Length-2)] -join "/")
        $destParent = $destDb.GetItem($destParentPath)
        if (-not $destParent) {
            Write-Output "Target parent item '$destParentPath' does not exist in '$Using:targetDb'. Skipping."
            Write-Output ""
            break
        }
        $resultList = @()
        $refList = [ref] $resultList
        $newItem = Copy-ItemWithOriginalId -srcItem $srcItem -destParent $destParent -destDb $destDb -recursive $recursiveFlag -resultList $refList

        # Output summary
        Write-Output ""
        Write-Output ("SOURCE in '" + $Using:sourceDb + "':")
        Write-Output "    '$($srcItem.Paths.FullPath)' (ID: $($srcItem.ID))"

        if ($resultList.Count -gt 1) {
            Write-Output ("TARGETS in '" + $Using:targetDb + "':")
            foreach ($r in $resultList) {
                Write-Output "    '$($r.Path)' - {$($r.Id)}"
            }
        } else {
            $r = $resultList | Select-Object -First 1
            Write-Output ("TARGET in '" + $Using:targetDb + "':")
            Write-Output "    '$($r.Path)' - {$($r.Id)}"
        }
    }

}
Stop-ScriptSession -Session $session