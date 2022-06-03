#This demo shows how to use OSDCloud rebooting to Audit Mode and running OOBEDeploy
#You can modify your OSDCloud WinPE by running the following command
#Edit-OSDCloud.winpe -WebPSScript 'https://raw.githubusercontent.com/OSDeploy/OSDCloud/main/Samples/AuditModeOOBEDeploy.ps1'
Write-Host  -ForegroundColor Cyan 'Demo OSDCloud Audit Mode OOBEDeploy'
Start-Sleep -Seconds 10
#=======================================================================
#   Set-DisRes
#=======================================================================
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor DarkCyan 'Setting Virtual Machine Display Resolution to 1600x'
    Write-Host  -ForegroundColor DarkCyan 'Set-DisRes 1600'
    Set-DisRes 1600
}
#=======================================================================
#   OSD Module
#=======================================================================
Write-Host  -ForegroundColor DarkCyan 'Install-Module OSD -Force'
Install-Module OSD -Force
Write-Host  -ForegroundColor Cyan 'Import-Module OSD -Force'
Import-Module OSD -Force
#=======================================================================
#   Start-OSDCloudGUI
#=======================================================================
Start-OSDCloudGUI
#=======================================================================
#   Unattend.xml
#=======================================================================
$AuditUnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <Reseal>
                <Mode>Audit</Mode>
            </Reseal>
        </component>
    </settings>
    <settings pass="auditUser">
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
            
            <RunSynchronousCommand wcm:action="add">
            <Order>1</Order>
            <Description>Setting PowerShell ExecutionPolicy</Description>
            <Path>PowerShell -WindowStyle Hidden -Command "Set-ExecutionPolicy RemoteSigned -Force"</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>2</Order>
            <Description>Update OSD Module</Description>
            <Path>PowerShell -Command "Install-Module OSD -Force"</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>3</Order>
            <Description>OOBEDeploy</Description>
            <Path>PowerShell -Command "Start-OOBEDeploy -AddRSAT -AddNetFX3 -UpdateDrivers -UpdateWindows -RemoveAppx CommunicationsApps,OfficeHub,People,Skype,Solitaire,Xbox,Zune"</Path>
            </RunSynchronousCommand>

            </RunSynchronous>
        </component>
    </settings>
</unattend>
'@
#=======================================================================
#   Audit Mode
#=======================================================================
$PantherUnattendPath = 'C:\Windows\Panther\Unattend'
if (-NOT (Test-Path $PantherUnattendPath)) {
    New-Item -Path $PantherUnattendPath -ItemType Directory -Force | Out-Null
}

$AuditUnattendPath = Join-Path $PantherUnattendPath 'Unattend.xml'

Write-Host -ForegroundColor Cyan "Set Unattend.xml at $AuditUnattendPath"
$AuditUnattendXml | Out-File -FilePath $AuditUnattendPath -Encoding utf8

Write-Host -ForegroundColor Cyan 'Use-WindowsUnattend'
Use-WindowsUnattend -Path 'C:\' -UnattendPath $AuditUnattendPath -Verbose
#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host  -ForegroundColor Cyan 'WinPE will reboot in 15 seconds'
Start-Sleep -Seconds 15
Write-Host  -ForegroundColor DarkCyan 'Restart-Computer'
Restart-Computer
