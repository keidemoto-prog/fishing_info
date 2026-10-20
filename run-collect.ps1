# Daily collector runner for the fishing catch/ocean log.
# Called 4x/day by Windows Task Scheduler. Manual test: powershell -ExecutionPolicy Bypass -File run-collect.ps1
# ASCII-only on purpose so Windows PowerShell 5.1 parses it regardless of BOM.

$ErrorActionPreference = "Continue"
$dir     = $PSScriptRoot
$claude  = "C:\Users\DEMOTO\.local\bin\claude.exe"
$stamp   = Get-Date -Format "yyyy-MM-dd"
$logFile = Join-Path $dir ("logs\run-{0}.log" -f $stamp)

# This vault (and this script) is synced to 4 PCs via Dropbox, but only ONE machine must
# actually collect + commit + push, or the pushes collide. Run only on the designated PC.
$RUNNER_PC = "DESKTOP-DLBHAAC"   # home PC. To move the job: change this + register the task there.
New-Item -ItemType Directory -Force (Join-Path $dir "logs") | Out-Null
if ($env:COMPUTERNAME -ne $RUNNER_PC) {
    Add-Content -Encoding utf8 $logFile ("`r`n=== {0} skipped on {1} (runner = {2}) ===" -f (Get-Date -Format "yyyy-MM-dd HH:mm"), $env:COMPUTERNAME, $RUNNER_PC)
    exit 0
}

Set-Location $dir
Add-Content -Encoding utf8 $logFile ("`r`n=== {0} start ===" -f (Get-Date -Format "yyyy-MM-dd HH:mm"))

# Do NOT pass the instruction text as an argument: PS 5.1 mangles long/quoted argv for native
# exes (that leaked "-NoProfile" from the .md into claude and broke every run). Instead give
# claude a short ASCII prompt and let it open the instruction file itself.
$task = 'This folder has a Japanese instruction file: the single .md file whose name is NOT README.md. Read that file completely and carry out every numbered step in it, from step 1 to the last step.'

# Decode claude's UTF-8 output correctly so the Japanese text in the logs is readable.
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

# Auth: the normal browser login expires about every 30 days (it broke the job on 2026-09-15
# and 2026-10-16). setup-claude-token.ps1 creates a 1-year token and stores it encrypted (DPAPI,
# this Windows user only) OUTSIDE the vault and repo. If that file exists we use it; if not, or
# if the token is rejected, we fall back to the normal stored login.
$tokenFile = Join-Path $env:USERPROFILE ".fishing-claude-token.dpapi"
$authMode  = "stored-login"
if (Test-Path $tokenFile) {
    try {
        $sec  = ConvertTo-SecureString (Get-Content -Raw $tokenFile).Trim()
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
        $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        if ($plain -like "sk-ant-*") { $env:CLAUDE_CODE_OAUTH_TOKEN = $plain; $authMode = "long-lived-token" }
        $plain = $null
    } catch { }
}
Add-Content -Encoding utf8 $logFile ("auth: {0}" -f $authMode)

$out = & $claude -p $task --dangerously-skip-permissions --add-dir $dir 2>&1 | ForEach-Object { $_.ToString() }
$claudeExit = $LASTEXITCODE
$out | Out-File -Append -Encoding utf8 $logFile

if ($claudeExit -ne 0 -and $authMode -eq "long-lived-token" -and (($out -join "`n") -match "authenticate")) {
    Add-Content -Encoding utf8 $logFile "auth: long-lived token was rejected -> retrying once with the stored login"
    Remove-Item Env:CLAUDE_CODE_OAUTH_TOKEN -ErrorAction SilentlyContinue
    $out = & $claude -p $task --dangerously-skip-permissions --add-dir $dir 2>&1 | ForEach-Object { $_.ToString() }
    $claudeExit = $LASTEXITCODE
    $out | Out-File -Append -Encoding utf8 $logFile
}
Remove-Item Env:CLAUDE_CODE_OAUTH_TOKEN -ErrorAction SilentlyContinue

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

    # Stage ONLY the collector's own known output paths - never "add -A". This folder is
    # synced live to 3 other PCs; a stray file dropped here by mistake (2026-09-11: a note
    # with live API keys, unrelated to this project, landed in this folder and got swept
    # into a commit by "add -A", blocking every push for 5 days via GitHub push protection)
    # must never be auto-committed. Anything genuinely new to track goes in by hand.
    & git -C $dir add -- data/catch-log.js data/catch-log.sample.js docs/index.html docs/.nojekyll tsuriha_all-in-one.html logs/ `
        2>&1 | ForEach-Object { $_.ToString() } | Out-File -Append -Encoding utf8 $gitLog
    & git -C $dir commit -m ("auto: collect {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm")) 2>&1 | ForEach-Object { $_.ToString() } | Out-File -Append -Encoding utf8 $gitLog
    & git -C $dir push                      2>&1 | ForEach-Object { $_.ToString() } | Out-File -Append -Encoding utf8 $gitLog
    $pushExit = $LASTEXITCODE
    $unpushed = (& git -C $dir rev-list --count "origin/main..HEAD" 2>$null)
    Add-Content -Encoding utf8 $logFile ("git: push exit {0}, unpushed commits: {1}" -f $pushExit, $unpushed)
}
