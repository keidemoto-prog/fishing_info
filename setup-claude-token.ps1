# One-time helper: creates a 1-year Claude Code token for the unattended fishing-log collector
# and stores it ENCRYPTED (DPAPI = readable only by this Windows user on this PC) in
# %USERPROFILE%\.fishing-claude-token.dpapi - outside the vault and outside the git repo.
# run-collect.ps1 uses that file automatically. The token is read from the CLIPBOARD, never typed
# into chat or saved in any note.
# ASCII-only on purpose (Windows PowerShell 5.1). The Japanese messages live in
# setup-claude-token-msg.txt next to this file.
# Run: double-click setup-claude-token.cmd  (or: powershell -ExecutionPolicy Bypass -File setup-claude-token.ps1)

$ErrorActionPreference = "Continue"
$claude    = "C:\Users\DEMOTO\.local\bin\claude.exe"
$tokenFile = Join-Path $env:USERPROFILE ".fishing-claude-token.dpapi"
$msgFile   = Join-Path $PSScriptRoot "setup-claude-token-msg.txt"

$M = @{}
Get-Content -Encoding UTF8 $msgFile | ForEach-Object {
    if ($_ -match '^([a-z_0-9]+)=(.*)$') { $M[$Matches[1]] = ($Matches[2] -replace '\\n', "`n") }
}
function Say($k) { Write-Host ""; Write-Host $M[$k] }

if (-not (Test-Path $claude)) { Say 'no_claude'; Read-Host $M['press_enter'] | Out-Null; exit 1 }

Say 'intro'
Read-Host $M['press_enter'] | Out-Null

# Interactive: opens the browser, you approve, and the 1-year token is printed on screen.
& $claude setup-token

# Read the token from the clipboard (up to 3 tries; the token stays visible on screen).
$tok = $null
for ($try = 1; $try -le 3 -and -not $tok; $try++) {
    Say 'ask_copy'
    Read-Host $M['press_enter'] | Out-Null
    $clip = Get-Clipboard -Raw
    if (-not $clip) { Say 'clip_bad'; continue }
    $lines = $clip -split "`r?`n"
    for ($i = 0; $i -lt $lines.Count -and -not $tok; $i++) {
        if ($lines[$i].Trim() -match '(sk-ant-[A-Za-z0-9_\-]+)') {
            $cand = $Matches[1]
            # the token may have been wrapped over several screen lines: join pure-token lines
            for ($j = $i + 1; $j -lt $lines.Count; $j++) {
                $n = $lines[$j].Trim()
                if ($n -match '^[A-Za-z0-9_\-]+$') { $cand += $n } else { break }
            }
            if ($cand.Length -ge 80 -and $cand.Length -le 300) { $tok = $cand }
        }
    }
    if (-not $tok) { Say 'clip_bad' }
}
if (-not $tok) { Say 'give_up'; Read-Host $M['press_enter'] | Out-Null; exit 1 }

# Test the token with a tiny request BEFORE saving it.
Say 'testing'
$env:CLAUDE_CODE_OAUTH_TOKEN = $tok
$reply = & $claude -p "Reply with exactly the single word OK" 2>&1 | Out-String
$testExit = $LASTEXITCODE
Remove-Item Env:CLAUDE_CODE_OAUTH_TOKEN -ErrorAction SilentlyContinue

if ($testExit -eq 0 -and $reply -match 'OK') {
    ConvertTo-SecureString $tok -AsPlainText -Force | ConvertFrom-SecureString | Set-Content -Encoding ASCII $tokenFile
    try { Set-Clipboard -Value " " } catch { }
    $tok = $null
    Say 'test_ok'
} else {
    $tok = $null
    Say 'test_ng'
}
Read-Host $M['press_enter'] | Out-Null
