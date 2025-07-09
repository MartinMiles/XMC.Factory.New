###
#   Usage:
#       .\Set-FieldValue-FromFile.ps1 -ItemPath "/sitecore/layout/Renderings/Feature/Zont/News/Latest News" -FieldName "ComponentQuery" -FilePath ".\GraphQL\LatestNews.gql"
###
param(
    [string]$ItemPath,
    [string]$FieldName,
    [string]$FilePath
)


[string]$FieldValue = ""
if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
    Write-Output "ERROR: File does not exist at path: $FilePath"
    return
}

# Try reading the file content
try {
    $FieldValue = Get-Content -Path $FilePath -Raw
    if ([string]::IsNullOrWhiteSpace($FieldValue)) {
        Write-Output "ERROR: File is empty or contains only whitespace."
        return
    }
}
catch {
    Write-Output "ERROR: Failed to read file content. Exception: $($_.Exception.Message)"
    return
}

Set-Location -Path $PSScriptRoot

$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json
Import-Module -Name SPE
$session = New-ScriptSession -ConnectionUri $config.connectionUri -Username $config.username -SharedSecret $config.SPE_REMOTING_SECRET
Invoke-RemoteScript -Session $session -ScriptBlock {

    function ExitWithError($message) {
        Write-Output "Error: $message"
        exit 1
    }

    # 1. Validate input parameters
    if ([string]::IsNullOrWhiteSpace($Using:ItemPath)) {
        ExitWithError "ItemPath is empty. Please provide a valid Sitecore path."
    }
    if ([string]::IsNullOrWhiteSpace($Using:FieldName)) {
        ExitWithError "FieldName is empty. Please provide a valid field name."
    }
    if ([string]::IsNullOrWhiteSpace($Using:FieldValue)) {
        ExitWithError "FieldValue is empty. Please provide a non-empty value to set."
    }

    # 2. Get the item
    $item = Get-Item -Path $Using:ItemPath
    if (-not $item) {
        ExitWithError "The item at path '$Using:ItemPath' does not exist."
    }

    # 3. Check if field exists
    $fieldDefinition = $item.Fields | Where-Object { $_.Name -eq $Using:FieldName }
    if (-not $fieldDefinition) {
        ExitWithError "Field '$Using:FieldName' does not exist on item at '$Using:ItemPath'."
    }

    # 4. Set the field value inside editing context
    try {
        $item.Editing.BeginEdit()
        $item[$Using:FieldName] = $Using:FieldValue
        $item.Editing.EndEdit() | Out-Null
    }
    catch {
        ExitWithError "Failed to set field value. Error: $_"
    }

    # 5. Confirm update
    $updatedValue = $item[$Using:FieldName]
    if ($updatedValue -eq $Using:FieldValue) {
        Write-Output "Field was set as:"
        Write-Output ""
        Write-Output $Using:FieldValue
    }
    else {
        ExitWithError "Failed to confirm update. Field value is '$updatedValue', expected '$Using:FieldValue'."
    }
}
Stop-ScriptSession -Session $session