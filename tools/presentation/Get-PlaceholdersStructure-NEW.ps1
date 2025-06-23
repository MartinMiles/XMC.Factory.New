<#
.SYNOPSIS
  Parse Sitecore debug comments into a JSON hierarchy,
  with single-slash breadcrumbs for nested placeholders,
  proper placeholder keys (UID+path), no duplicate UIDs,
  collapsing consecutive slashes, and stripping leading
  slashes from top-level placeholders.

.PARAMETER Url
  Defaults to http://rssbplatform.dev.local/more-info

.PARAMETER OutputPath
  Optional, if omitted, writes JSON to console
#>
param(
  [string]$Url,
  [string]$OutputPath
)

# 1) Download HTML
try {
  Write-Output "Downloading HTML from $Url"
  $req         = [System.Net.HttpWebRequest]::Create($Url)
  $req.Timeout = 10000
  $res         = $req.GetResponse()
  $content     = (New-Object System.IO.StreamReader($res.GetResponseStream())).ReadToEnd()
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
    $node = [PSCustomObject]@{
      name         = $meta.name
      id           = $meta.id
      uid          = $meta.uid
      placeholder  = $origPh
      path         = $meta.path
      key          = $key
      placeholders = @{ }
    }

    if ($meta.uid -eq $rootUid -and $meta.placeholder -eq $rootPlaceholder -and $meta.name -eq $rootName) {
      $root = $node
    }

    if (-not $current.placeholders.ContainsKey($origPh)) {
      $current.placeholders[$origPh] = @()
    }
    $current.placeholders[$origPh] += $node

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

# 7) Emit JSON, fix slashes, trim whitespace, collapse blank lines
$json = $root | ConvertTo-Json -Depth 20

# collapse consecutive slashes
$json = $json -replace '/{2,}', '/'

# strip leading slash from placeholder values
$json = $json -replace '"placeholder":"/([^/"]+)"', '"placeholder":"$1"'

# trim trailing whitespace on each line
$json = (
  $json -split '\r?\n' |
  ForEach-Object { $_.TrimEnd() }
) -join "`n"

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
