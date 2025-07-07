param(
    [string]$PageItemPath = "/sitecore/content/Zont/Habitat/Home/target"
)

Set-Location -Path $PSScriptRoot

$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json
Write-Output "ConnectionUri: $($config.connectionUri)"
Write-Output "Username     : $($config.username)"
Write-Output "SPE Remoting Secret : $($config.SPE_REMOTING_SECRET)"

Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri -Username $config.username -SharedSecret $config.SPE_REMOTING_SECRET
Invoke-RemoteScript -Session $session -ScriptBlock {



    [string]$LayoutItemPath = "/sitecore/layout/Layouts/Foundation/JSS Experience Accelerator/Presentation/JSS Layout"



# 1. Mount "master:" drive if missing
if (-not (Get-PSDrive -Name master -ErrorAction SilentlyContinue)) {
    try {
        New-PSDrive -Name master -PSProvider Sitecore -Root "/" -Database "master" -ErrorAction Stop | Out-Null
        Write-Output "Mounted master: drive."
    }
    catch {
        Write-Output " Could not mount master: $_.Exception.Message"
        return
    }
}

# 2. Get master database
$db = [Sitecore.Configuration.Factory]::GetDatabase("master")
if ($null -eq $db) {
    Write-Output " Unable to retrieve master database."
    return
}

# 3. Load the page item
$pageItem = Get-Item -Path ("master:" + $Using:PageItemPath) -ErrorAction SilentlyContinue
if ($null -eq $pageItem) {
    Write-Output " Page item not found at: master: $Using:PageItemPath"
    return
}

# 4. Load the layout item
$layoutItem = Get-Item -Path ("master:" + $LayoutItemPath) -ErrorAction SilentlyContinue
if ($null -eq $layoutItem) {
    Write-Output " Layout item not found at: master:$LayoutItemPath"
    return
}

# 5. Read existing __Renderings XML
$existingXml = $pageItem.Fields[[Sitecore.FieldIDs]::LayoutField].Value

# 6. Parse (or create) XmlDocument for <r>...</r>
[xml]$xmlDoc = $null
if ([string]::IsNullOrWhiteSpace($existingXml)) {
    # No current Shared Layout → new <r> root
    $xmlDoc = New-Object System.Xml.XmlDocument
    $root   = $xmlDoc.CreateElement("r")
    # Add namespace declarations exactly as Sitecore expects
    $root.SetAttribute("xmlns:p", "p")
    $root.SetAttribute("xmlns:s", "s")
    $root.SetAttribute("p:p", "1")
    $xmlDoc.AppendChild($root) | Out-Null
}
else {
    try {
        $xmlDoc = New-Object System.Xml.XmlDocument
        $xmlDoc.LoadXml($existingXml)
    }
    catch {
        Write-Output "Failed to parse existing __Renderings XML: $_.Exception.Message"
        return
    }
}

# 7. Grab namespace URIs from the root (<r>) element
$root = $xmlDoc.DocumentElement
# Typically these return "p" and "s"
$nsP = $root.GetNamespaceOfPrefix("p")
$nsS = $root.GetNamespaceOfPrefix("s")

# 8. Find the single <d> under <r>
#    (This is the device node where your renderings live.)
$dNode = $xmlDoc.SelectSingleNode("/r/d")
if ($null -eq $dNode) {
    Write-Output "No <d> device node found under <r> in Shared Layout. Cannot update layout."
    return
}

# 9. Compute the new layout GUID (uppercase, with braces)
$layoutGuid = $layoutItem.ID.Guid.ToString("B").ToUpper()

# 10. Set or overwrite the "s:l" attribute on <d> to point to our new layout
#     (This leaves all child <r>… elements intact.)
$dNode.SetAttribute("l", $nsS, $layoutGuid)

# 11. Also add "p:before"="*" so that Sitecore knows to insert this layout before existing renderings
$dNode.SetAttribute("before", $nsP, "*")

# 12. Ensure that <r> root still has the correct namespace declarations and p:p="1"
#     (If they were missing initially, we already added them in step 6.)

# 13. Serialize back to a string
$updatedXml = $root.OuterXml

# 14. Write back into the __Renderings field (Shared Layout)
try {
    $pageItem.Editing.BeginEdit()
    $pageItem.Fields[[Sitecore.FieldIDs]::LayoutField].Value = $updatedXml
    $pageItem.Editing.EndEdit()

    Write-Output " Shared Layout updated successfully."
    Write-Output "   Page:   master:$Using:PageItemPath  (ID: $($pageItem.ID))"
    Write-Output "   Layout: master:$LayoutItemPath (ID: $($layoutItem.ID))"
}
catch {
    if ($pageItem -and $pageItem.Editing.IsEditing) {
        $pageItem.Editing.CancelEdit()
    }
    Write-Output " Error writing Shared Layout: $_.Exception.Message"
    throw
}

# 15. Verification: print out new __Renderings XML so you can confirm it kept your child <r> nodes
Write-Output "New __Renderings content (Shared Layout):"
Write-Output $updatedXml


}
Stop-ScriptSession -Session $session