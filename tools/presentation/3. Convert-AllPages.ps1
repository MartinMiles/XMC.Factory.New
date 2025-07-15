# Parameters for the mapping script
param(
    $SiteRoot      = "/sitecore/content/Zont/Habitat/Home",
    $DatabaseName  = "master",
    $UrlBase       = "http://rssbplatform.dev.local",
    $IncludeHome   = $false
)

# Path to the mapping script and the script to call for each item
$mappingScriptPath = Join-Path $PSScriptRoot "Map-NewPagesToOldUrls.ps1"
$secondScriptPath  = Join-Path $PSScriptRoot "2. Convert-PageLayout.ps1"

# Call the mapping script and capture JSON output
try {
    $jsonResult = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $mappingScriptPath @arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Map-NewPagesToOldUrls.ps1 failed with exit code $LASTEXITCODE. Output:`n$jsonResult"
        exit 1
    }
}
catch {
    Write-Error "Failed to run "
    exit 2
}

# Parse JSON output
try {
    $resultObject = $jsonResult | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse JSON output from Map-NewPagesToOldUrls.ps1: $_"
    exit 3
}



# For each key-value pair, call the second script
foreach ($pair in $resultObject) {
    $itemPath = $pair.PagePath
    $Url      = $pair.Url

    write-output "Processing itemPath: $itemPath ==> $Url"
    try {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $secondScriptPath -itemPath $pair.PagePath -Url $pair.Url
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "SecondScript.ps1 failed for $itemPath with exit code $LASTEXITCODE."
        }
    }
    catch {
        Write-Warning "Error calling SecondScript.ps1"
    }
}

Write-Output "All done."