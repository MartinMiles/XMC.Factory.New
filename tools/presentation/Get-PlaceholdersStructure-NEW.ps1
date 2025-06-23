param(
  [string]$Url,
  [string]$OutputPath
)

# 1) Download HTML
try {
  $req            = [System.Net.WebRequest]::Create($Url)
  $req.Method     = 'GET'
  $req.Timeout    = 10000
  $res            = $req.GetResponse()
  $content        = (New-Object System.IO.StreamReader($res.GetResponseStream())).ReadToEnd()
  $res.Close()
}
catch {
  Write-Error "Error downloading '$Url': $_"
  exit 1
}

# 2) Extract component markers
$pattern = "<!--\s*(start|end)-component='(?<json>[^']+)'\s*-->"
$matches = [regex]::Matches(
  $content, $pattern,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)
if ($matches.Count -eq 0) {
  Write-Error "No component markers found."
  exit 1
}

# 3) Helper to parse JSON-like metadata
function Convert-ComponentStringToObject {
  param([string]$str)
  $json = $str -replace '(\w+)\s*:', '"$1":'
  try { return $json | ConvertFrom-Json -ErrorAction Stop }
  catch { throw "Invalid metadata JSON: $str" }
}

# 4) Initialize parsing state
$rootUid         = '00000000-0000-0000-0000-000000000000'
$rootPlaceholder = ''
$rootName        = 'Default'
$placeholderMappings = @{
    "page-layout" = "headless-main"
    "header-top"  = "headless-header"
    "footer"      = "headless-footer"
}
$root            = $null

# Dummy container to root the tree
$container  = [PSCustomObject]@{ placeholders = @{}; key = 'container' }
$current    = $container
$stack      = New-Object System.Collections.Stack
$ignoreKeys = @()

# 5) Build the tree
foreach ($m in $matches) {
  $type   = $m.Groups[1].Value
  $meta   = Convert-ComponentStringToObject $m.Groups['json'].Value
  $origPh = ($meta.placeholder -split '/')[ -1 ]
  $key    = "$($meta.uid)|$($meta.path)"

  if ($type -eq 'start') {
    if ($key -eq $current.key) {
      $ignoreKeys += $key
      continue
    }
    # Compute xmc property
    if ($meta.uid -eq $rootUid) {
      $xmcValue = ""
    }
    elseif ($current.uid -eq $rootUid) {
      $mappingKey = $origPh.ToLower()
      if ($placeholderMappings.ContainsKey($mappingKey)) {
        $xmcValue = $placeholderMappings[$mappingKey]
      }
      else {
        $xmcValue = $origPh
      }
    }
    else {
      $parentXmc = $current.xmc.TrimStart('/')
      $xmcValue   = "/$parentXmc/$origPh"
    }

    $node = [PSCustomObject]@{
      name         = $meta.name
      id           = $meta.id
      uid          = $meta.uid
      placeholder  = $origPh
      xmc          = $xmcValue
      path         = $meta.path
      key          = $key
      placeholders = @{ }
    }

    if ($meta.uid -eq $rootUid -and $meta.placeholder -eq $rootPlaceholder -and $meta.name -eq $rootName) {
      $root = $node
    }

    if ($current.placeholders.ContainsKey($origPh)) {
      $current.placeholders[$origPh] += $node
    }
    else {
      $current.placeholders[$origPh] = @($node)
    }
    $stack.Push($current)
    $current = $node
  }
  else {
    if ($ignoreKeys -contains $key) {
      $ignoreKeys = $ignoreKeys | Where-Object { $_ -ne $key }
      continue
    }
    if ($key -eq $current.key) {
      if ($stack.Count -gt 0) {
        $current = $stack.Pop()
      }
      else {
        throw "No parent on stack for component end: $($meta.name) [$key]"
      }
    }
  }
}

# 6) Validate none remain
if ($stack.Count -ne 0) {
  Write-Error "Unmatched components remain:"
  while ($stack.Count -gt 0) {
    $n = $stack.Pop()
    Write-Error " - $($n.name) [$($n.key)]"
  }
  exit 1
}
if (-not $root) {
  Write-Error "No root component parsed."
  exit 1
}

# 7) Output JSON
$json = ($root | ConvertTo-Json -Depth 100 | ForEach-Object { $_.TrimEnd() }) -join "`n"
# collapse multiple blank lines into one
$json = $json -replace "(`n){2,}", "`n"

if ($OutputPath) {
  # write UTF8 without BOM so editors see pure LF
  $json | Out-File $OutputPath -Encoding utf8
  Write-Output "JSON written to $OutputPath"
}
else {
  Write-Output $json
}
