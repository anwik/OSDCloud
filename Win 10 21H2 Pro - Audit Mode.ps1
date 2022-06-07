Write-Host  -ForegroundColor Cyan 'OSDCloud Autopilot Audit Mode Demo'
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
            <Description>Install OOBEDeploy Module</Description>
            <Path>PowerShell -Command "Install-Module OOBEDeploy -Force"</Path>
            </RunSynchronousCommand>

            <RunSynchronousCommand wcm:action="add">
            <Order>3</Order>
            <Description>OOBEDeploy</Description>
            <Path>PowerShell -Command "Start-OOBEDeploy"</Path>
            </RunSynchronousCommand>

            </RunSynchronous>
        </component>
    </settings>
</unattend>
'@

#================================================
#  [PostOS] OOBEDeploy Configuration
#================================================
Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json"
$OOBEDeployJson = @'
{
    "Autopilot":  {
                      "IsPresent":  false
                  },
    "AddNetFX3":  {
                      "IsPresent":  true
                    },                     
    "RemoveAppx":  [
                       "Microsoft.549981C3F5F10",
                        "Microsoft.BingWeather",
                        "Microsoft.GetHelp",
                        "Microsoft.Getstarted",
                        "Microsoft.Microsoft3DViewer",
                        "Microsoft.MicrosoftOfficeHub",
                        "Microsoft.MicrosoftSolitaireCollection",
                        "Microsoft.MixedReality.Portal",
                        "Microsoft.People",
                        "Microsoft.SkypeApp",
                        "Microsoft.Wallet",
                        "Microsoft.WindowsCamera",
                        "microsoft.windowscommunicationsapps",
                        "Microsoft.WindowsFeedbackHub",
                        "Microsoft.WindowsMaps",
                        "Microsoft.Xbox.TCUI",
                        "Microsoft.XboxApp",
                        "Microsoft.XboxGameOverlay",
                        "Microsoft.XboxGamingOverlay",
                        "Microsoft.XboxIdentityProvider",
                        "Microsoft.XboxSpeechToTextOverlay",
                        "Microsoft.YourPhone",
                        "Microsoft.ZuneMusic",
                        "Microsoft.ZuneVideo"
                   ],
    "UpdateDrivers":  {
                          "IsPresent":  true
                      },
    "UpdateWindows":  {
                          "IsPresent":  true
                      }
}
'@
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$OOBEDeployJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json" -Encoding ascii -Force

#================================================
#  [PostOS] AutopilotOOBE Configuration Staging
#================================================
Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json"
$AutopilotOOBEJson = @'
{
    "Assign":  {
                   "IsPresent":  true
               },
    "GroupTag":  "Karlstad",
    "AddToGroup": "Intune Config - Defender for Endpoint EDR",
    "Hidden":  [
                   "AssignedComputerName",
                   "AssignedUser",
                   "PostAction",
                   "GroupTag",
                   "Assign",
                   "Run",
                   "Docs"
               ],
    "PostAction":  "Quit",
    "Title":  "ANWIK Autopilot OOBE Demo"
}
'@
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$AutopilotOOBEJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json" -Encoding ascii -Force


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
