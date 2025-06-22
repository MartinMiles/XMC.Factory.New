<#
.SYNOPSIS
  Parse Sitecore debug comments into a JSON hierarchy,
  with single-slash breadcrumbs for nested placeholders,
  proper placeholder keys, no duplicate UIDs,
  collapsing consecutive slashes, and stripping leading
  slashes from top-level placeholders.

.PARAMETER Url
  Defaults to http://rssbplatform.dev.local/about-habitat

.PARAMETER OutputPath
  Optional; if omitted, writes JSON to console.
#>
param(
  [string]$Url        = 'http://rssbplatform.dev.local/more-info',
  [string]$OutputPath
)

# 1) Download HTML
try {
  Write-Output "Downloading HTML from $Url"
  $req     = [System.Net.HttpWebRequest]::Create($Url)
  $req.Timeout = 10000
  $res     = $req.GetResponse()
  $content = (New-Object System.IO.StreamReader($res.GetResponseStream())).ReadToEnd()
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

# 4) Initialize
$rootUid         = '00000000-0000-0000-0000-000000000000'
$rootPlaceholder = ''
$rootName        = 'Default'
$stack           = @()
$ignoreUids      = @()
$root            = $null

# 5) Build the tree
foreach ($m in $matches) {
  $type = $m.Groups[1].Value
  $meta = Convert-ComponentStringToObject $m.Groups['json'].Value

  # Placeholder-array key = last segment of raw placeholder
  $rawPh  = $meta.placeholder
  $origPh = ($rawPh -split '/')[ -1 ]

  $isRoot = (
    $meta.uid         -eq $rootUid         -and
    $meta.placeholder -eq $rootPlaceholder -and
    $meta.name        -eq $rootName
  )

  if ($type -eq 'start') {
    # 5.a) Ignore if same UID as parent
    if ($root -and $stack.Count -gt 0) {
      $parent = $stack[-1]
      if ($meta.uid -eq $parent.uid) {
        $ignoreUids += $meta.uid
        continue
      }
    }

    # 5.b) Create node
    $node = [PSCustomObject]@{
      name         = $meta.name
      id           = $meta.id
      uid          = $meta.uid
      placeholder  = $origPh
      path         = $meta.path
      placeholders = @{}
    }

    if (-not $root) {
      $root = $node
    }
    else {
      $parent = $stack[-1]

      # 5.c) Drop duplicates by UID in same array
      if ($parent.placeholders.ContainsKey($origPh) -and
          ($parent.placeholders[$origPh] | Where-Object { $_.uid -eq $meta.uid })) {
        continue
      }

      # 5.d) Add node under origPh
      if (-not $parent.placeholders.ContainsKey($origPh)) {
        $parent.placeholders[$origPh] = @()
      }
      $parent.placeholders[$origPh] += $node

      # 5.e) If depth ≥2, build single-slash breadcrumb
      if ($stack.Count -gt 1) {
        $labels = @()
        for ($i = 1; $i -lt $stack.Count; $i++) {
          $labels += ($stack[$i].placeholder -split '/')[ -1 ]
        }
        $labels += $origPh
        $node.placeholder = '/' + ($labels -join '/')
      }
    }

    # 5.f) Push node
    $stack += $node
  }
  else {
    # end-component

    # 5.g) Drop ignored‐UID
    if ($ignoreUids -contains $meta.uid) {
      $ignoreUids = $ignoreUids | Where-Object { $_ -ne $meta.uid }
      continue
    }
    if ($isRoot) { continue }

    # Pop LIFO
    if ($stack.Count -gt 0) {
      $stack = $stack[0..($stack.Count - 2)]
    }
    else {
      throw "Found an end-component with no open start-component."
    }
  }
}

# 6) Validate
if ($stack.Count -gt 1) {
  Write-Error "Unmatched components remain:"
  $stack[0..($stack.Count - 2)] |
    ForEach-Object { Write-Error " - $($_.name) [UID: $($_.uid)]" }
  exit 1
}
if (-not $root) {
  Write-Error "No root component parsed."
  exit 1
}

# 7) Emit JSON and clean up slashes
$json = $root | ConvertTo-Json -Depth 20
# 7.a) Collapse any run of 2+ forward-slashes into a single '/'
$json = $json -replace '/{2,}', '/'
# 7.b) Remove a single leading slash for placeholder values that have no other slash
$json = $json -replace '"placeholder":"/([^/"]+)"', '"placeholder":"$1"'

if ($OutputPath) {
  $json | Out-File $OutputPath -Encoding UTF8
  Write-Output "JSON written to $OutputPath"
}
else {
  Write-Output $json
}
