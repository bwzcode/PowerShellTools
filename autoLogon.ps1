#Powershell Script to Enable AutoLogon
#By: Brian Zhu

# Script Path
$scriptPath = $MyInvocation.MyCommand.Path

# Check if running as Admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb "RunAs" -ArgumentList "-File $scriptPath -NoExit"
    exit 0
}#if

# Domain Account Prompt
$filePrompt = Read-Host "Is this a Domain Account? [Y/N] "
if($filePrompt  -eq 'Y' -or $filePrompt  -eq 'y'){
    $AutoLogonDomain = (Get-WmiObject Win32_ComputerSystem).Domain
    Write-Host "Domain: $AutoLogonDomain"
}#if
else{
    
}#else

# Prompt for User Input
Write-Host "Please enter the Username & Password you would like to use for AutoLogon"

# Get User Input for AutoLogon Values
$AutoLogonUser = Read-Host "Username"
$AutoLogonPassword = Read-Host "Password"

# Define the registry key path for automatic logon
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Check if the "DefaultPassword" registry value exists
if (Test-Path -Path "$RegistryPath\DefaultPassword") {
    Write-Host "The 'DefaultPassword' registry value already exists."
}# if 
else {
    #Create DefaultPassword registry value if it does not exist
    New-ItemProperty -Path $RegistryPath -Name "DefaultPassword" -Value $AutoLogonPassword -PropertyType String -Force | Out-Null
}# else

#Set Values to all Registry Items
Set-ItemProperty -Path $RegistryPath -Name "DefaultUserName" -Value $AutoLogonUser
Set-ItemProperty -Path $RegistryPath -Name "AutoAdminLogon" -Value 1

#Line for Separation
Write-Host "------------------------------------------------------------------------------"
Write-Host "AutoLogon has been setup, the Computer will Restart upon exit to Apply Changes"
Write-Host "------------------------------------------------------------------------------"
Read-Host -Prompt "Press Enter to exit"

# Restart the computer to apply the changes
Restart-Computer -Force