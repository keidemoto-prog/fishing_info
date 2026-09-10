# Daily collector runner for the fishing catch/ocean log.
# Called 4x/day by Windows Task Scheduler. Manual test: powershell -ExecutionPolicy Bypass -File run-collect.ps1
# ASCII-only on purpose so Windows PowerShell 5.1 parses it regardless of BOM.

$ErrorActionPreference = "Continue"
$dir     = $PSScriptRoot
$claude  = "C:\Users\DEMOTO\.local\bin\claude.exe"
$stamp   = Get-Date -Format "yyyy-MM-dd"
$logFile = Join-Path $dir ("logs\run-{0}.log" -f $stamp)

New-Item -ItemType Directory -Force (Join-Path $dir "logs") | Out-Null
Set-Location $dir
Add-Content -Encoding utf8 $logFile ("`r`n=== {0} start ===" -f (Get-Date -Format "yyyy-MM-dd HH:mm"))

# Do NOT pass the instruction text as an argument: PS 5.1 mangles long/quoted argv for native
# exes (that leaked "-NoProfile" from the .md into claude and broke every run). Instead give
# claude a short ASCII prompt and let it open the instruction file itself.
$task = 'This folder has a Japanese instruction file: the single .md file whose name is NOT README.md. Read that file completely and carry out every numbered step in it, from step 1 to the last step.'

& $claude -p $task --dangerously-skip-permissions --add-dir $dir 2>&1 |
    ForEach-Object { $_.ToString() } | Out-File -Append -Encoding utf8 $logFile
$claudeExit = $LASTEXITCODE

# Rebuild the standalone / docs / artifact files from whatever the run produced.
& (Join-Path $dir "build-single.ps1") 2>&1 |
    ForEach-Object { $_.ToString() } | Out-File -Append -Encoding utf8 $logFile

Add-Content -Encoding utf8 $logFile ("=== {0} end (claude exit {1}) ===" -f (Get-Date -Format "yyyy-MM-dd HH:mm"), $claudeExit)

# Commit + push so GitHub Pages (keidemoto-prog/fishing_info -> docs/) picks up the new data.
# Full git chatter -> non-tracked logs\git-*.log (git prints progress to stderr, which PS 5.1
# renders noisily even on success - that noise is harmless). A one-line PASS/FAIL + unpushed-
# count summary also goes to the tracked run log so a real failure is easy to spot.
# First push must be done once by hand so the credential is cached; after that this is unattended.
if (Test-Path (Join-Path $dir ".git")) {
    $gitLog = Join-Path $dir ("logs\git-{0}.log" -f $stamp)
    Add-Content -Encoding utf8 $gitLog ("--- {0} ---" -f (Get-Date -Format "yyyy-MM-dd HH:mm"))

    # Pull first: 4 PCs sync this vault, so origin/main may be ahead of this working copy.
    & git -C $dir pull --rebase --autostash 2>&1 | ForEach-Object { $_.ToString() } | Out-File -Append -Encoding utf8 $gitLog
    & git -C $dir add -A                    2>&1 | ForEach-Object { $_.ToString() } | Out-File -Append -Encoding utf8 $gitLog
    & git -C $dir commit -m ("auto: collect {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm")) 2>&1 | ForEach-Object { $_.ToString() } | Out-File -Append -Encoding utf8 $gitLog
    & git -C $dir push                      2>&1 | ForEach-Object { $_.ToString() } | Out-File -Append -Encoding utf8 $gitLog
    $pushExit = $LASTEXITCODE
    $unpushed = (& git -C $dir rev-list --count "origin/main..HEAD" 2>$null)
    Add-Content -Encoding utf8 $logFile ("git: push exit {0}, unpushed commits: {1}" -f $pushExit, $unpushed)
}
