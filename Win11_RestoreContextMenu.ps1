#Win11_RestoreContextMenu.ps1
#By: Brian Zhu
#Restores the Full Windows Context Menu to Windows 11 via Registry Changes

#Run as Admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    #Change the path to -File as needed
    Start-Process powershell.exe -Verb "RunAs" -ArgumentList "-File E:\Code\Powershell\Win11_RestoreContextMenu.ps1 -NoExit"
    exit 0
}

#Initial screen & prompt
Write-Host 
"***********************************************************************"
"*              Windows 11 Context Menu Restore Script                 *"
"***********************************************************************"
#Line for Separation
Write-Host "-----------------------------------------------------------------------"
Write-Host "Working on registry changes..."
# Set registry values for classic context menu
New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -Force | Out-Null
# Restart Windows Explorer to apply changes
Stop-Process -Name explorer
#Line for Separation
Write-Host "-----------------------------------------------------------------------"
Write-Host "Context menu has been restored!"
Write-Host "-----------------------------------------------------------------------"
Read-Host -Prompt "Press Enter to exit"