# Add necessary assemblies for MessageBox
Add-Type -AssemblyName PresentationCore,PresentationFramework

# Display a message box with Yes, No, and Cancel options
$ButtonType = [System.Windows.MessageBoxButton]::YesNoCancel
$MessageIcon = [System.Windows.MessageBoxImage]::Information 
$MessageBody = "Your biometric is enabled. Would you like to configure your biometric sign-in options?"
$MessageTitle = "Biometric authentication is enabled"
$Result = [System.Windows.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)

# Output the result of the message box choice
Write-Host "Your choice is $Result"

# Check if biometric authentication is enabled in the registry (Windows Hello)
$registryKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" 
$biometricStatus = Get-ItemProperty -Path $registryKeyPath -Name "AllowDomainPINLogon" -ErrorAction SilentlyContinue

# Check if the registry value exists and if biometric authentication is enabled
if ($biometricStatus) {
    if ($biometricStatus.EnableAdvancedBiometrics -eq 1) {
        Write-Host "Biometric authentication (Windows Hello) is enabled. You can configure it."
    } else {
        Write-Host "Biometric authentication (Windows Hello) is disabled."
    }
} else {
    # Show a MessageBox if the registry key is missing
    #$MessageBody = "Registry key for biometric authentication not found. It might be missing or unavailable."
    #$MessageTitle = "Biometric Configuration Error"
    #[System.Windows.MessageBox]::Show($MessageBody, $MessageTitle, [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
}

 Ask if the user wants to open Accounts settings
$MessageBoxResult = [System.Windows.MessageBox]::Show('Do you want to open the Accounts settings?', 'Open Accounts Settings', $ButtonType)

# Perform action based on the user's choice
if ($MessageBoxResult -eq [System.Windows.MessageBoxResult]::Yes) {
     Open the Accounts settings if "Yes" is selected
    Start-Process "ms-settings:signinoptions"
} elseif ($MessageBoxResult -eq [System.Windows.MessageBoxResult]::No) {
     #Do nothing if "No" is selected
    Write-Host 'No action taken.'
} else {
    # Do nothing if "Cancel" is selected
    Write-Host 'Action canceled.'
}
