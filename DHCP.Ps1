# Get all DHCP scopes
$Scopes = Get-DhcpServerv4Scope -ComputerName $DhcpServer

# Iterate through each scope
foreach ($Scope in $Scopes) {
$ScopeId = $Scope.ScopeId
$ScopeName = $Scope.Name

# Get scope statistics
$ScopeStats = Get-DhcpServerv4ScopeStatistics -ComputerName $DhcpServer -ScopeId $ScopeId

# Calculate free IP addresses
$FreeIPs = $ScopeStats.Free
$TotalIPs = $ScopeStats.Total
$UsedIPs = $TotalIPs - $FreeIPs

Write-Host "Scope: $ScopeName ($ScopeId)"
Write-Host "Total IPs: $TotalIPs, Used IPs: $UsedIPs, Free IPs: $FreeIPs"

# Check if free IPs are below threshold
if ($FreeIPs -lt $Threshold) {
Write-Warning "WARNING: Scope $ScopeName ($ScopeId) has low available IPs ($FreeIPs left)!"

# Send alert via email (optional)
$SMTPServer = "smtp.yourdomain.com"
$From = "dhcp-monitor@yourdomain.com"
$To = "admin@yourdomain.com"
$Subject = "DHCP Scope Low IP Alert: $ScopeName"
$Body = "Warning: DHCP Scope $ScopeName ($ScopeId) has only $FreeIPs available IPs left."

Send-MailMessage -To $To -From $From -Subject $Subject -Body $Body -SmtpServer $SMTPServer
}
}