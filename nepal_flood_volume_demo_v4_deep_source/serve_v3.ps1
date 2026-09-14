$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# Find a free port so an older V2 server cannot be reopened by accident.
$port = $null
foreach ($candidate in 8767..8785) {
  try {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $candidate)
    $listener.Start()
    $listener.Stop()
    $port = $candidate
    break
  } catch {}
}
if (-not $port) {
  Add-Type -AssemblyName PresentationFramework
  [System.Windows.MessageBox]::Show('No free local port was found between 8767 and 8785. Close old viewer windows and try again.','Nepal Flood Volume Demo V3') | Out-Null
  exit 1
}

$pythonFile = $null
$pythonArgs = $null
if (Get-Command py -ErrorAction SilentlyContinue) {
  $pythonFile = 'py'
  $pythonArgs = @('-3','-m','http.server',"$port",'--bind','127.0.0.1')
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
  $pythonFile = 'python'
  $pythonArgs = @('-m','http.server',"$port",'--bind','127.0.0.1')
}
if (-not $pythonFile) {
  Add-Type -AssemblyName PresentationFramework
  [System.Windows.MessageBox]::Show('Python was not found. A local web server is required for Cesium.','Nepal Flood Volume Demo V3') | Out-Null
  exit 1
}

$server = Start-Process -FilePath $pythonFile -ArgumentList $pythonArgs -WorkingDirectory $root -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 2
if ($server.HasExited) {
  Add-Type -AssemblyName PresentationFramework
  [System.Windows.MessageBox]::Show('The local server did not start. Close any previous viewer server and try again.','Nepal Flood Volume Demo V3') | Out-Null
  exit 1
}

$url = "http://127.0.0.1:$port/?build=v3-corrected"
Start-Process $url
Write-Host ''
Write-Host 'Nepal Flood VOLUME DEMO V3 CORRECTED is running at:' -ForegroundColor Cyan
Write-Host $url -ForegroundColor Yellow
Write-Host ''
Write-Host 'Keep this window open. Press ENTER to stop the viewer.'
Read-Host | Out-Null
if (!$server.HasExited) { Stop-Process -Id $server.Id -Force }
