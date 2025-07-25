param(
    [string]$SitemapUrl = "http://rssbplatform.dev.local/sitemap.xml",
    [string]$OutputPath
)

function Clean-And-ParseJson {
    param (
        [string]$JsonRaw
    )

    # Step 1: Remove invisible/invalid characters
    $cleanJson = -join ($JsonRaw.ToCharArray() | Where-Object {
        # Keep printable ASCII (char codes 32–126) and valid UTF-8 newlines/tabs
        ($_ -match '[\u0020-\u007E\u0009\u000A\u000D]')
    })

    # Step 2: Minify (remove all line breaks and tabs)
    $minifiedJson = $cleanJson -replace '[\r\n\t]', '' -replace '\s{2,}', ' '

    # Step 3: Validate and parse
    try {
        $parsed = $minifiedJson | ConvertFrom-Json -ErrorAction Stop
        Write-Host "JSON parsed successfully."
        return $parsed
    }
    catch {
        # Step 4: Extract detailed error
        Write-Warning "JSON parsing failed."
        Write-Warning "Error: $($_.Exception.Message)"

        # Dump snippet around the location if available
        if ($_.Exception.LineNumber -and $_.Exception.Position) {
            $line = $_.Exception.LineNumber
            $pos = $_.Exception.Position
            Write-Host "`n--- JSON Context ---"
            $lines = $minifiedJson -split "`n"
            if ($lines.Length -ge $line) {
                $snippet = $lines[$line - 1]
                Write-Host "Line $line :`n$snippet"
                Write-Host (" " * ($pos - 1)) + "^"
            }
        }
        else {
            # Fallback: show a snippet of failing area
            $partial = $minifiedJson.Substring(0, [Math]::Min($minifiedJson.Length, 500))
            Write-Host "`n--- Partial JSON Start ---"
            Write-Host $partial
        }

        throw "JSON parsing failed. Review error above."
    }
}


function Get-SitemapUrls {
    param(
        [string]$sitemapUrl
    )
    $webClient = New-Object System.Net.WebClient
    $xmlContent = $webClient.DownloadString($sitemapUrl)
    [xml]$xmlDoc = $xmlContent

    $urls = @()
    foreach ($urlNode in $xmlDoc.urlset.url) {
        $loc = $urlNode.loc
        if ($loc) {
            $urls += $loc
        }
    }
    return $urls
}

$mapping = @{}

function Process-Node {
    param(
        $node
    )
    if ($null -eq $node.id) { return }

    $childPlaceholders = @()
    if ($node.placeholders -and $node.placeholders.PSObject.Properties.Count -gt 0) {
        foreach ($phName in $node.placeholders.PSObject.Properties.Name) {
            $children = $node.placeholders.$phName
            if ($children) {
                $childPlaceholders += $phName
                foreach ($child in $children) {
                    Process-Node $child
                }
            }
        }
    }

    if ($mapping.ContainsKey($node.id)) {
        $all = @($mapping[$node.id]) + @($childPlaceholders)
        $flat = @()
        foreach ($item in $all) {
            if ($null -ne $item) {
                if ($item -is [System.Array]) {
                    $flat += $item
                } else {
                    $flat += $item
                }
            }
        }
        $uniq = $flat | Where-Object { $_ -ne $null -and $_ -ne "" } | Select-Object -Unique
        $mapping[$node.id] = $uniq
    } else {
        $mapping[$node.id] = $childPlaceholders | Where-Object { $_ -ne $null -and $_ -ne "" } | Select-Object -Unique
    }
}

$allUrls = Get-SitemapUrls -sitemapUrl $SitemapUrl

foreach ($pageUrl in $allUrls) {
    try {
        # Write-Host "Processing $pageUrl"
        $jsonOutput = & .\Get-PlaceholdersStructure-NEW.ps1 -Url $pageUrl -OutputPath $OutputPath

        if (-not $jsonOutput -or $jsonOutput.Trim() -eq "") {
            Write-Warning "No output or empty JSON returned for $pageUrl"
            continue
        }
        try {
            $data = $jsonOutput | ConvertFrom-Json
        } catch {
            Write-Warning "Invalid JSON received for $pageUrl"
             Write-Warning "Exception: $($_.Exception.Message)"
            continue
        }

        $data = $jsonOutput | ConvertFrom-Json
        Process-Node $data
    }
    catch {
        Write-Warning "Failed to process $pageUrl : $_"
        continue
    }
}

$finalMapping = @{}
foreach ($k in $mapping.Keys) {
    if ($mapping[$k] -and $mapping[$k].Count -gt 0) {
        $finalMapping[$k] = $mapping[$k] -join "|"
    } else {
        $finalMapping[$k] = ""
    }
}

$finalMapping | ConvertTo-Json -Depth 100
# | Out-File $OutputPath -Encoding utf8
