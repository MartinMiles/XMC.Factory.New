
param(
    [Parameter(Mandatory = $false)]
    [string]$Url = "http://rssbplatform.dev.local/about-habitat",

    [Parameter(Mandatory = $false)]
    [string]$ItemPath = "/sitecore/content/Zont/Habitat/Home/target"
)

#------------------------------------------------------------
# 1. Determine script folder (so we can write files relative to it)
#------------------------------------------------------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not (Test-Path $scriptDir)) {
    Write-Error "Cannot determine script directory. Exiting."
    exit 1
}

#------------------------------------------------------------
# 2. Invoke Get-Layout.ps1 to retrieve Layout JSON for $ItemPath
#------------------------------------------------------------
$layoutScript = Join-Path $scriptDir "Get-Layout.ps1"
if (-not (Test-Path $layoutScript)) {
    Write-Error "Cannot find Get-Layout.ps1 in '$scriptDir'. Please ensure it exists."
    exit 1
}

Write-Host "Invoking Get-Layout.ps1 for item path '$ItemPath' ..."
try {
    $layoutJsonRaw = & $layoutScript -itemPath $ItemPath 2>&1
} catch {
    Write-Error "Failed to execute Get-Layout.ps1: $_"
    exit 1
}

if (-not $layoutJsonRaw) {
    Write-Error "Get-Layout.ps1 returned no output. Exiting."
    exit 1
}

$layoutJsonString = $layoutJsonRaw | Out-String
try {
    $layoutObj = $layoutJsonString | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse Layout JSON returned by Get-Layout.ps1. $_"
    exit 1
}

#------------------------------------------------------------
# 3. Build UID -> PlaceholderKey map from Layout JSON
#------------------------------------------------------------
$layoutMap = @{}

function Traverse-Layout {
    param($placeholdersArray)

    foreach ($ph in $placeholdersArray) {
        $phString = $ph.placeholder
        $segments = $phString -split "/"
        $shortKey = $segments[-1]

        foreach ($rend in $ph.renderings) {
            if ($rend.uid) {
                $uidStr = ($rend.uid.Trim('{','}')).ToLower()
                $layoutMap[$uidStr] = $shortKey
            } else {
                Write-Warning "Skipping rendering with no UID in layout JSON."
            }

            if ($rend.placeholders -and $rend.placeholders.Count -gt 0) {
                Traverse-Layout $rend.placeholders
            }
        }
    }
}

if (-not $layoutObj.placeholders) {
    Write-Error "Layout JSON does not contain a 'placeholders' property. Exiting."
    exit 1
}
Traverse-Layout $layoutObj.placeholders

#------------------------------------------------------------
# 4. Fetch the rendered HTML from $Url
#------------------------------------------------------------
Write-Host "Downloading HTML from $Url ..."
try {
    $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Error "Failed to download URL '$Url'. $_"
    exit 1
}
$html = $response.Content
if (-not $html) {
    Write-Error "Downloaded HTML is empty. Exiting."
    exit 1
}

#------------------------------------------------------------
# 5. Locate all start-component / end-component markers in the HTML
#------------------------------------------------------------
$patternStart = "<!--\s*start-component='({.*?})'\s*-->"
$patternEnd   = "<!--\s*end-component='({.*?})'\s*-->"

$regexStart = [regex]::new(
    $patternStart,
    [System.Text.RegularExpressions.RegexOptions]::Singleline -bor
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)
$regexEnd = [regex]::new(
    $patternEnd,
    [System.Text.RegularExpressions.RegexOptions]::Singleline -bor
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

$matchesStart = $regexStart.Matches($html)
$matchesEnd   = $regexEnd.Matches($html)

$markers = @()

foreach ($m in $matchesStart) {
    $jsonText = $m.Groups[1].Value
    try {
        $meta = ConvertFrom-Json -InputObject $jsonText -ErrorAction Stop
    } catch {
        Write-Error "Malformed JSON in start-component: $jsonText"
        exit 1
    }
    $uid = ($meta.uid.Trim('{','}')).ToLower()
    $markers += [PSCustomObject]@{
        Type   = "Start"
        UID    = $uid
        Name   = $meta.name
        Path   = $meta.path
        Index  = $m.Index
        Length = $m.Length
    }
}

foreach ($m in $matchesEnd) {
    $jsonText = $m.Groups[1].Value
    try {
        $meta = ConvertFrom-Json -InputObject $jsonText -ErrorAction Stop
    } catch {
        Write-Error "Malformed JSON in end-component: $jsonText"
        exit 1
    }
    $uid = ($meta.uid.Trim('{','}')).ToLower()
    $markers += [PSCustomObject]@{
        Type   = "End"
        UID    = $uid
        Name   = $meta.name
        Path   = $meta.path
        Index  = $m.Index
        Length = $m.Length
    }
}

$markers = $markers | Sort-Object Index

Write-Host "`nFound the following markers in the HTML:`n"
foreach ($mark in $markers) {
    Write-Host ("  {0,-5} | UID={1} | Index={2}" -f $mark.Type, $mark.UID, $mark.Index)
}
Write-Host ""

#------------------------------------------------------------
# 6. Build a nested “component tree” by using a stack
#------------------------------------------------------------
$stack      = @()
$components = @()

foreach ($marker in $markers) {
    switch ($marker.Type) {
        "Start" {
            $node = [PSCustomObject]@{
                UID            = $marker.UID
                Name           = $marker.Name
                Path           = $marker.Path
                StartIndex     = $marker.Index + $marker.Length
                EndIndex       = $null
                RawHtml        = ""
                Children       = @()
                PlaceholderKey = ""
            }
            if ($stack.Count -gt 0) {
                $parent = $stack[-1]
                $parent.Children += $node
            } else {
                $components += $node
            }
            $stack += $node
        }
        "End" {
            if ($stack.Count -eq 0) {
                Write-Error "Unmatched end-component for UID '$($marker.UID)'."
                exit 1
            }
            $node = $stack[-1]
            if ($node.UID -ne $marker.UID) {
                Write-Error "Nesting error: end-marker UID '$($marker.UID)' does not match start UID '$($node.UID)'."
                exit 1
            }

            $node.EndIndex = $marker.Index
            $length       = $node.EndIndex - $node.StartIndex
            try {
                $node.RawHtml = $html.Substring($node.StartIndex, $length)
            } catch {
                Write-Error "Failed to extract RawHtml for UID '$($node.UID)': $_"
                exit 1
            }

            if ($stack.Count -gt 1) {
                $stack = $stack[0 .. ($stack.Count - 2)]
            } else {
                $stack = @()
            }
        }
    }
}

if ($stack.Count -gt 0) {
    $leftover = $stack[-1]
    Write-Error "Unmatched start-component for UID '$($leftover.UID)'. Missing end marker."
    exit 1
}

if ($components.Count -ne 1) {
    Write-Warning "Expected exactly one top-level component (the holding view), but found $($components.Count). Proceeding with the first one."
}
$root = $components[0]

#------------------------------------------------------------
# 7. Verify all UIDs (except the root) exist in the layout map; warn if missing
#------------------------------------------------------------
function Get-AllNodes {
    param($node)
    $list = @($node)
    foreach ($c in $node.Children) {
        $list += Get-AllNodes $c
    }
    return $list
}
$allNodes = Get-AllNodes $root

foreach ($node in $allNodes) {
    if ($node.UID -eq "00000000-0000-0000-0000-000000000000") {
        continue
    }
    if (-not $layoutMap.ContainsKey($node.UID)) {
        Write-Warning "Layout JSON mismatch: UID '$($node.UID)' (component '$($node.Name)') not found in layout map. That component will be skipped."
        $node.PlaceholderKey = ""
    } else {
        $node.PlaceholderKey = $layoutMap[$node.UID]
    }
}

#------------------------------------------------------------
# 8. Helper: Convert raw HTML -> minimal valid JSX (strip comments, class->className)
#------------------------------------------------------------
function ConvertHtmlToJsx {
    param([string]$htmlContent)
    if (-not $htmlContent) { return "" }
    # Remove ALL HTML comments
    $noComments = [regex]::Replace($htmlContent, "<!--.*?-->", "", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    # Convert class="..." to className="..."
    $jsx = $noComments -replace 'class="([^"]*)"', 'className="$1"'
    return $jsx
}

#------------------------------------------------------------
# 9. Recursively write each component’s TSX file
#------------------------------------------------------------
function Write-ComponentTsx {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$node,
        [Parameter(Mandatory = $true)]
        [string]$scriptDir
    )

    # Build output path: remove leading “/” or “~” from $node.Path, then change extension
    $trimmed = $node.Path -replace '^[~/]+', ''   # strip any leading “/” or “~”
    $relativeUnix = $trimmed
    $relativeWin  = $relativeUnix -replace "/", "\"
    $tsPath       = [IO.Path]::ChangeExtension($relativeWin, ".tsx")
    $fullPath     = Join-Path $scriptDir $tsPath
    $dir          = Split-Path $fullPath -Parent

    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $componentName = $node.Name -replace "\s", ""
    $writer        = [System.IO.StreamWriter]::new($fullPath, $false, [System.Text.Encoding]::UTF8)

    # 9.1 Write imports + interface
    $writer.WriteLine("import {")
    $writer.WriteLine("  ComponentParams,")
    $writer.WriteLine("  ComponentRendering,")
    $writer.WriteLine("  Placeholder,")
    $writer.WriteLine("} from '@sitecore-jss/sitecore-jss-nextjs';")
    $writer.WriteLine("import React from 'react';")
    $writer.WriteLine()
    $writer.WriteLine("interface ComponentProps {")
    $writer.WriteLine("  rendering: ComponentRendering & { params: ComponentParams };")
    $writer.WriteLine("  params: ComponentParams;")
    $writer.WriteLine("}")
    $writer.WriteLine()
    $writer.WriteLine("const $componentName = (props: ComponentProps): JSX.Element => {")
    $writer.WriteLine("  return (")
    $writer.WriteLine("    <>")

    # 9.2 Group children by PlaceholderKey, skipping any child whose PlaceholderKey is empty
    $validChildren = $node.Children | Where-Object { $_.PlaceholderKey -ne "" }

    if ($validChildren.Count -gt 0) {
        $groups   = $validChildren | Group-Object PlaceholderKey
        $modified = $node.RawHtml

        # Build ranges per group
        $groupRanges = @()
        foreach ($grp in $groups) {
            $key      = $grp.Name
            $minStart = [int]::MaxValue
            $maxEnd   = 0
            foreach ($child in $grp.Group) {
                $childHtml = $child.RawHtml
                $idx       = $modified.IndexOf($childHtml)
                if ($idx -lt 0) {
                    Write-Error "Could not locate raw HTML for child UID '$($child.UID)' in parent '$($node.UID)'."
                    exit 1
                }
                if ($idx -lt $minStart) { $minStart = $idx }
                $endPos = $idx + $childHtml.Length
                if ($endPos -gt $maxEnd) { $maxEnd = $endPos }
            }
            $groupRanges += [PSCustomObject]@{ Key = $key; Start = $minStart; End = $maxEnd }
        }

        # Sort descending by Start so earlier replacements do not shift later
        $sortedRanges = $groupRanges | Sort-Object Start -Descending
        foreach ($range in $sortedRanges) {
            $before = $modified.Substring(0, $range.Start)
            $after  = $modified.Substring($range.End)
            $phTag  = "<Placeholder name=`"$($range.Key)`" rendering={props.rendering} />"
            $modified = $before + $phTag + $after
        }

        # Convert to JSX and write
        $jsxContent = ConvertHtmlToJsx $modified
        $lines = $jsxContent -split "`r?`n"
        foreach ($line in $lines) {
            $writer.WriteLine("      $line")
        }
    }
    else {
        # No valid children; just output RawHtml (strip comments, convert classes)
        $jsxContent = ConvertHtmlToJsx $node.RawHtml
        $lines      = $jsxContent -split "`r?`n"
        foreach ($line in $lines) {
            $writer.WriteLine("      $line")
        }
    }

    $writer.WriteLine("    </>")
    $writer.WriteLine("  );")
    $writer.WriteLine("};")
    $writer.WriteLine()
    $writer.WriteLine("export default $componentName;")
    $writer.Close()

    Write-Host " - Generated component: $tsPath"

    foreach ($child in $node.Children) {
        Write-ComponentTsx -node $child -scriptDir $scriptDir
    }
}

if (-not $root.Children -or $root.Children.Count -eq 0) {
    Write-Warning "No child components found under the top-level holding view. Nothing to generate."
} else {
    foreach ($child in $root.Children) {
        Write-ComponentTsx -node $child -scriptDir $scriptDir
    }
}

#------------------------------------------------------------
# 10. Generate Layout.tsx in the script folder (exactly as in example)
#------------------------------------------------------------
$layoutPath = Join-Path $scriptDir "Layout.tsx"
@"
import React from 'react';
import Head from 'next/head';
import { Placeholder, LayoutServiceData, Field, HTMLLink } from '@sitecore-jss/sitecore-jss-nextjs';
import config from 'temp/config';
import Scripts from 'src/Scripts';

// Prefix public assets with a public URL to enable compatibility with Sitecore Experience Editor.
// If you're not supporting the Experience Editor, you can remove this.
const publicUrl = config.publicUrl;

interface LayoutProps {
  layoutData: LayoutServiceData;
  headLinks: HTMLLink[];
}

interface RouteFields {
  [key: string]: unknown;
  Title?: Field;
}

const Layout = ({ layoutData, headLinks }: LayoutProps): JSX.Element => {
  const { route } = layoutData.sitecore;
  const fields = route?.fields as RouteFields;
  const isPageEditing = layoutData.sitecore.context.pageEditing;
  const mainClassPageEditing = isPageEditing ? 'editing-mode' : 'prod-mode';

  return (
    <>
      <Scripts />
      <Head>
        <title>{fields?.Title?.value?.toString() || 'Page'}</title>
        <link rel="icon" href={`${publicUrl}/favicon.ico`} />
        {headLinks.map((headLink) => (
          <link rel={headLink.rel} key={headLink.href} href={headLink.href} />
        ))}
      </Head>

      {/* root placeholder for the app, which we add components to using route data */}
      <div className={mainClassPageEditing}>
        <header>
          <div id="header">{route && <Placeholder name="headless-header" rendering={route} />}</div>
        </header>
        <main>
          <div id="content">{route && <Placeholder name="headless-main" rendering={route} />}</div>
        </main>
        <footer>
          <div id="footer">{route && <Placeholder name="headless-footer" rendering={route} />}</div>
        </footer>
      </div>
    </>
  );
};

export default Layout;
"@ | Out-File -FilePath $layoutPath -Encoding utf8

Write-Host " - Generated Layout.tsx in $scriptDir"
Write-Host "`nAll components and Layout.tsx have been generated successfully." -ForegroundColor Green
