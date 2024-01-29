<# 
# Network Info PowerShell Script
# Gathers MAC Addresses on a machine & their current IP Address
# By: Brian Zhu 
#>

#Variables
$CurrentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

#Get Network Interfaces
$networkInterfaces = Get-NetAdapter | Where-Object { $_.PhysicalMediaType -eq '802.3' }

#Output
Write-Host 
"***********************************************************************"
"*                         Network Info Script                         *"
"***********************************************************************"
#Date and Time
Write-Host "Script executed successfully on: $CurrentDateTime" -ForegroundColor Yellow

#Initial Header
Write-Host "`n    MAC Address   | IP Address  | Status `n" -ForegroundColor Blue

#Display MAC addresses, IP addresses, and interface status side by side
foreach ($interface in $networkInterfaces) {
    $macAddress = $interface.MacAddress
    $ipAddress = (Get-NetIPAddress -InterfaceIndex $interface.IfIndex | Where-Object { $_.AddressFamily -eq 'IPv4' }).IPAddress
    $status = if ($interface.Status -eq 'Up') {
        'Active'
        $statusColor = "Green"
    }#if
    else {
        'Inactive'
        $statusColor = "Red"
    }#else
    Write-Host "$macAddress | $ipAddress | $status" -ForegroundColor $statusColor
}#foreach

Write-Host "`n"
#Wait for User Input to exit
Read-Host -Prompt "Script Completed, Press Enter to exit"