<# 
# Quick Info PowerShell Script
# Gathers Useful Information about the current machine
# Information is displayed & also saved to a .txt dump file
# By: Brian Zhu 
#>

#Script Path
$scriptPath = $MyInvocation.MyCommand.Path

#Check if running as Admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb "RunAs" -ArgumentList "-File $scriptPath -NoExit"
    exit 0
}#if

#Output File
$outFile = "C:\QuickInfoSummary.txt"

#Variables
$CurrentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$serviceTag = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
$model = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model
$vendor = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer
$hostname = hostname
$domain = (Get-WmiObject Win32_ComputerSystem).Domain
$netAdapters = Get-NetAdapter -Physical | Select-Object Name, InterfaceDescription, MacAddress

#Seperate netAdapters string for Console Output & File Output
$netAdaptersConsole = $netAdapters | Format-Table -AutoSize | Out-String
$netAdaptersFile = $netAdapters | Format-Table -AutoSize | Out-String

#Pull IMEI via netsh
$imei = netsh.exe mbn show interfaces | find "Device Id"
#Check IMEI Values are empty
#IMEI
if ([string]::IsNullOrEmpty($imei)) {
    $imei = "IMEI Unavailable, AirCard not detected"
    $imeiColor = "Red"
}#if
else {
    $imei = $imei.Split(":")[1].Trim()
    $imeiColor = "Green"
}#else

#Pull ICCID via netsh (deprecated in Win11)
#$iccid = netsh.exe mbn show readyinfo * | findstr "SIM Telephone"

#Pull ICCID via Registry Entry
$iccidRegistry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Multivariant\UI\Candidates\UICC")
if ($null -eq $iccidRegistry) {
    $iccid = "ICCID Unavailable, SIM Card not detected"
    $iccidColor = "Red"
}#if
else {
    $subkeyNames = $iccidRegistry.GetSubKeyNames()
    if ($subkeyNames.Length -eq 0) {
        $iccid = "ICCID Unavailable, SIM Card not detected"
        $iccidColor = "Red"
    }#if
    else {
        $iccid = $subkeyNames[0]
        $iccidColor = "Green"
    }#else
}#else

#Output
Write-Host 
"***********************************************************************"
"*                          Quick Info Script                          *"
"***********************************************************************"
#Date and Time
Write-Host "Script executed successfully on: $CurrentDateTime" -ForegroundColor Yellow
#Computer Info
Write-Host "`nComputer Information" -ForegroundColor Magenta
Write-Host "Computer Model: $vendor $model" -ForegroundColor Green
Write-Host "Service Tag: $serviceTag" -ForegroundColor Green
Write-Host "Hostname: $hostname" -ForegroundColor Green
Write-Host "Domain: $domain" -ForegroundColor Green
#Cellular Info
Write-Host "`nCellular Information" -ForegroundColor Magenta
Write-Host "IMEI: $imei" -ForegroundColor $imeiColor
Write-Host "ICCID: $iccid" -ForegroundColor $iccidColor 
#Network Adapters & MAC Addresses
Write-Host "`nNetwork Adapters & MAC Addresses" -ForegroundColor Magenta
$netAdaptersConsole | Write-Host -ForegroundColor Green
# Save to file
Write-Host "Exporting Computer Information to $outFile" -ForegroundColor Yellow
"Quick Info Script run on:$CurrentDateTime`r`n`r`nComputer Information`r`nComputer Model: $vendor $model`r`nService Tag: $serviceTag`r`nHostname: $hostname`r`nDomain: $domain`r`n`r`nCellular Information`r`nIMEI: $imei`r`nICCID: $iccid`r`n`r`nNetwork Adapters & MAC Addresses`r`n$netAdaptersFile" | Out-File -FilePath $outFile
#Wait for User Input to exit
Read-Host -Prompt "Script Completed, Press Enter to exit"