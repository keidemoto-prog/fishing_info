# Builds dependency-free single-file HTML from the viewer page + data/*.js
#   - tsuriha_all-in-one.html : full standalone HTML (for mail / offline use)
#   - docs/index.html         : same, served by GitHub Pages
#   - dist/artifact.html      : body-only, for publishing as a claude.ai Artifact
# Called by run-collect.ps1 every run. Manual: powershell -ExecutionPolicy Bypass -File build-single.ps1
# ASCII-only on purpose so Windows PowerShell 5.1 parses it regardless of BOM.

$dir = $PSScriptRoot
$srcFile = Get-ChildItem $dir -Filter *.html |
           Where-Object { $_.Name -ne 'tsuriha_all-in-one.html' } |
           Select-Object -First 1
if (-not $srcFile) { Write-Error "viewer .html not found in $dir"; exit 1 }

$src = Get-Content -Raw -Encoding UTF8 $srcFile.FullName
$d1  = Get-Content -Raw -Encoding UTF8 (Join-Path $dir "data\catch-log.js")
$d2  = Get-Content -Raw -Encoding UTF8 (Join-Path $dir "data\catch-log.sample.js")

$inline1 = "<script>`n$d1`n</script>"
$inline2 = "<script>`n$d2`n</script>"

$whole = $src.Replace('<script src="data/catch-log.js"></script>', $inline1).
              Replace('<script src="data/catch-log.sample.js"></script>', $inline2)

$body = $whole
$ti = $body.IndexOf('<title>')
if ($ti -ge 0) { $body = $body.Substring($ti) }
foreach ($t in '</head>', '<body>', '</body>', '</html>') { $body = $body.Replace($t, '') }

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $dir "tsuriha_all-in-one.html"), $whole, $utf8NoBom)
New-Item -ItemType Directory -Force (Join-Path $dir "dist") | Out-Null
[System.IO.File]::WriteAllText((Join-Path $dir "dist\artifact.html"), $body, $utf8NoBom)
New-Item -ItemType Directory -Force (Join-Path $dir "docs") | Out-Null
[System.IO.File]::WriteAllText((Join-Path $dir "docs\index.html"), $whole, $utf8NoBom)
# .nojekyll so GitHub Pages serves files/paths starting with underscore etc. as-is
[System.IO.File]::WriteAllText((Join-Path $dir "docs\.nojekyll"), "", $utf8NoBom)

Write-Output ("build-single: all-in-one {0} chars / docs/index.html {0} / dist/artifact.html {1}" -f $whole.Length, $body.Length)
