param(
    [string]$SiteRoot = "/sitecore/content/Zont/Habitat/Home",
    [string]$DatabaseName = "master",
    [string]$UrlBase = "http://rssbplatform.dev.local",
    [bool]$IncludeHome = $false,
    [string]$OutputPath
)

$UrlBase = $UrlBase.TrimEnd('/')

Set-Location -Path $PSScriptRoot

$config = Get-Content -Raw -Path ../remoting/config.LOCAL.json | ConvertFrom-Json

Import-Module SPE
$session = New-ScriptSession `
    -ConnectionUri $config.connectionUri `
    -Username      $config.username `
    -SharedSecret  $config.SPE_REMOTING_SECRET

$json = Invoke-RemoteScript -Session $session -ScriptBlock {

    $ErrorActionPreference = 'Stop'

    if (-not (Get-PSDrive -Name $Using:DatabaseName -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $Using:DatabaseName -PSProvider Sitecore -Root "/" -Database $Using:DatabaseName -ErrorAction Stop | Out-Null
    }

    $rootPath = $Using:DatabaseName + ":" + $Using:SiteRoot
    if (-not (Test-Path $rootPath -ErrorAction SilentlyContinue)) {
        throw "Site root '$Using:SiteRoot' not found in database '$Using:DatabaseName'."
    }

    function Test-Presentation {
        param([string]$layoutFieldValue)
        if ([string]::IsNullOrWhiteSpace($layoutFieldValue)) { return $false }
        $parts      = $layoutFieldValue -split '¤', 2
        $sharedXml  = $parts[0]
        $finalXml   = if ($parts.Length -gt 1) { $parts[1] } else { "" }
        return -not [string]::IsNullOrWhiteSpace($sharedXml) -or
               -not [string]::IsNullOrWhiteSpace($finalXml)
    }

    $results = @()
    $allItems = Get-ChildItem -Path $rootPath -Recurse -ErrorAction Stop

    $homeItem = Get-Item -Path $rootPath
    $homePath = $homeItem.Paths.Path
    $homePathParts = $homePath -split '/'

    if ($Using:IncludeHome) {
        $rawLayout = $homeItem["__Renderings"]
        if (Test-Presentation $rawLayout) {
            $results += [PSCustomObject]@{
                PagePath = $homePath
                Url      = $Using:UrlBase
            }
        }
    }

    foreach ($item in $allItems) {
        if ($item.Name -eq "__Standard Values" -or $item.Paths.Path -like "*/__Standard Values") { continue }
        if ($item.Paths.Path -eq $homePath) { continue }
        $rawLayout = $item["__Renderings"]
        if (Test-Presentation $rawLayout) {
            $itemPathParts = $item.Paths.Path -split '/'
            $relParts = $itemPathParts[$homePathParts.Count..($itemPathParts.Count - 1)]
            $relUrl = ($relParts | Where-Object { $_ -ne "" } | ForEach-Object { $_.ToLower().Replace(" ", "-") }) -join "/"
            $url = $Using:UrlBase + "/$relUrl"
            $results += [PSCustomObject]@{
                PagePath = $item.Paths.Path
                Url      = $url
            }
        }
    }

    Write-Output $results | ConvertTo-Json -Depth 5

}

Stop-ScriptSession -Session $session

# Output JSON to file if $OutputPath is provided, otherwise write to console
if (![string]::IsNullOrWhiteSpace($OutputPath)) {
    $json | Out-File -FilePath $OutputPath -Encoding utf8
} else {
    Write-Output $json
}
