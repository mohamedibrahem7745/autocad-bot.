# autocad-bridge.ps1
# Watches the "inbox" folder next to this file. Every new .scr file dropped there
# is run automatically in the active AutoCAD drawing (via COM), then moved to "done".
$ErrorActionPreference = 'Stop'
$base  = Split-Path -Parent $MyInvocation.MyCommand.Path
$inbox = Join-Path $base 'inbox'
$done  = Join-Path $base 'done'
$log   = Join-Path $base 'bridge.log'
New-Item -ItemType Directory -Force -Path $inbox, $done | Out-Null

function Log($m) {
  $line = "{0:yyyy-MM-dd HH:mm:ss}  {1}" -f (Get-Date), $m
  Write-Host $line
  Add-Content -Path $log -Value $line -Encoding UTF8
}
function Get-Acad {
  try { [Runtime.InteropServices.Marshal]::GetActiveObject('AutoCAD.Application') } catch { $null }
}

Log "autocad-bridge started, watching $inbox"
$lastWait = ''
while ($true) {
  $files = @(Get-ChildItem -Path $inbox -Filter *.scr -File | Sort-Object Name)
  foreach ($f in $files) {
    # make sure the file has finished being written
    $size = $f.Length; Start-Sleep -Milliseconds 500; $f.Refresh()
    if ($f.Length -ne $size) { continue }

    $acad = Get-Acad
    if (-not $acad) { if ($lastWait -ne 'acad') { Log 'waiting: AutoCAD is not running'; $lastWait = 'acad' }; break }
    $doc = $null; try { $doc = $acad.ActiveDocument } catch {}
    if (-not $doc) { if ($lastWait -ne 'doc') { Log 'waiting: no drawing is open'; $lastWait = 'doc' }; break }
    $lastWait = ''

    $target = Join-Path $done ("{0:yyyyMMdd-HHmmss}_{1}" -f (Get-Date), $f.Name)
    Move-Item -LiteralPath $f.FullName -Destination $target
    $p = $target -replace '\\', '/'
    $cmd = "(command `"_.SCRIPT`" `"$p`") "

    $ok = $false
    for ($i = 0; $i -lt 40 -and -not $ok; $i++) {
      try { $doc.SendCommand($cmd); $ok = $true } catch { Start-Sleep -Milliseconds 500 }
    }
    if ($ok) { Log "ran $($f.Name) in $($doc.Name)" } else { Log "FAILED to send $($f.Name) - AutoCAD busy?" }
  }
  Start-Sleep -Seconds 1
}
