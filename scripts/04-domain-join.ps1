Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses "10.0.1.4"
$retries = 0; $resolved = $false
do {
  Start-Sleep -Seconds 15; $retries++
  $resolved = [bool](Resolve-DnsName "lab.local" -ErrorAction SilentlyContinue)
  Write-Host " Attempt $retries -- resolved: $resolved"
} while (-not $resolved -and $retries -lt 12)
if (-not $resolved) { throw "lab.local did not resolve after 3 minutes." }
$securePw = ConvertTo-SecureString "ADMIN_PASSWORD" -AsPlainText -Force
$domainCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "LAB\azureadmin", $securePw
Add-Computer -DomainName "lab.local" -Credential $domainCred -Restart -Force
# VM restarts here. The orchestration script waits for it to come back online.
