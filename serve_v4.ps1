$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ports = 8786..8805
function Test-PortFree($port) {
  try {
    $client = New-Object System.Net.Sockets.TcpClient
    $iar = $client.BeginConnect('127.0.0.1',$port,$null,$null)
    $wait = $iar.AsyncWaitHandle.WaitOne(200)
    if ($wait -and $client.Connected) { $client.EndConnect($iar); $client.Close(); return $false }
    $client.Close(); return $true
  } catch { return $true }
}
$port = $ports | Where-Object { Test-PortFree $_ } | Select-Object -First 1
if (-not $port) { $port = 8795 }
Push-Location $root
Start-Process "http://127.0.0.1:$port/" | Out-Null
try { py -3 -m http.server $port }
catch {
  try { python -m http.server $port }
  catch {
    Start-Process (Join-Path $root 'index.html')
    Write-Host 'Python was not found. Opened index.html directly instead.'
    Read-Host 'Press Enter to close'
  }
}
Pop-Location
