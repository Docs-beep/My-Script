## Move user to inactive accounts in AD

$diabledAccount = Get-ADUser -Filter  {Enabled -eq $True} -SearchBase “OU=Disabled Users,DC=DEVLAB,DC=com” | Disable-ADAccount | Select-Object GivenName,SamAccountName,DistinguishedName,UserPrincipalName 

$diabledAccount = Get-ADUser -Filter * -SearchBase “OU=Disabled Users,DC=DEVLAB,DC=com” -Properties WhenChanged| Select-Object GivenName,SamAccountName,DistinguishedName,UserPrincipalName,WhenChanged  |Export-Csv "c:\temp\disbale.csv" 

##SMTP
$username = "user id "
$password = "password"
$sstr = ConvertTo-SecureString -string $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -argumentlist $username, $sstr
$body = "$diabledAccounts"
$attchment = "c:\temp\disbale.csv"
Send-MailMessage -To "" -From " -Subject 'Database Connecation monitoring' -Body test -Attachments $attchment -SmtpServer "smtp" -UseSSL -Credential $cred -Port 587
