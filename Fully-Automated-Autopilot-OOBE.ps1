#================================================
#   OSDCloud Task Sequence
#   Windows 10 21H2 Pro en-us Retail
#   No Autopilot
#   No Office Deployment Tool
#================================================
#   PreOS
#   Install and Import OSD Module
#================================================
Install-Module OSD -Force
Import-Module OSD -Force
#================================================
#   [OS] Start-OSDCloud with Params
#================================================
$Params = @{
    OSVersion = "Windows 10"
    OSBuild = "21H2"
    OSEdition = "Pro"
    OSLanguage = "sv-se"
    OSLicense = "Retail"
    SkipAutopilot = $true
    SkipODT = $true
    ZTI = $true
}
Start-OSDCloud @Params
#================================================
#   WinPE PostOS Sample
#   AutopilotOOBE Offline Staging
#================================================
Install-Module AutopilotOOBE -Force
Import-Module AutopilotOOBE -Force

$Params = @{
    Title = 'ANWIK Autopilot OOBE Registration'
    GroupTag = 'Karlstad'
    GroupTagOptions = 'Karlstad','Stockholm'
    Hidden = 'AddToGroup','AssignedComputerName','AssignedUser','PostAction'
    Assign = $true
    Run = 'NetworkingWireless'
    Docs = 'https://pornhub.com'
}
AutopilotOOBE @Params
#================================================
#   WinPE PostOS Sample
#   OOBEDeploy Offline Staging
#================================================
$Params = @{
    Autopilot = $true
    RemoveAppx = "CommunicationsApps","OfficeHub","People","Skype","Solitaire","Xbox","ZuneMusic","ZuneVideo"
    UpdateDrivers = $true
    UpdateWindows = $true
}
Start-OOBEDeploy @Params
#================================================
#   WinPE PostOS
#   Set OOBEDeploy CMD.ps1
#================================================
$SetCommand = @'
@echo off

:: Set the PowerShell Execution Policy
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force

:: Add PowerShell Scripts to the Path
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts

:: Open and Minimize a PowerShell instance just in case
start PowerShell -NoL -W Mi

:: Install the latest OSD Module
start "Install-Module OSD" /wait PowerShell -NoL -C Install-Module OSD -Force -Verbose

:: Start-OOBEDeploy
:: There are multiple example lines. Make sure only one is uncommented
:: The next line assumes that you have a configuration saved in C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json
start "Start-OOBEDeploy" PowerShell -NoL -C Start-OOBEDeploy
:: The next line assumes that you do not have a configuration saved in or want to ensure that these are applied
REM start "Start-OOBEDeploy" PowerShell -NoL -C Start-OOBEDeploy -AddNetFX3 -UpdateDrivers -UpdateWindows

exit
'@
$SetCommand | Out-File -FilePath "C:\Windows\OOBEDeploy.cmd" -Encoding ascii -Force
#================================================
#   WinPE PostOS
#   Set AutopilotOOBE CMD.ps1
#================================================
$SetCommand = @'
@echo off
ECHO Initialize Autopilot OOBE
ECHO Please standby....
:: Set the PowerShell Execution Policy
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force

:: Add PowerShell Scripts to the Path
set path=%path%;C:\Program Files\WindowsPowerShell\Scripts

:: Open and Minimize a PowerShell instance just in case
start PowerShell -NoL -W Mi

:: Install the latest AutopilotOOBE Module
start "Install-Module AutopilotOOBE" /wait PowerShell -NoL -C Install-Module AutopilotOOBE -Force -Verbose

:: Start-AutopilotOOBE
:: There are multiple example lines. Make sure only one is uncommented
:: The next line assumes that you have a configuration saved in C:\ProgramData\OSDeploy\OSDeploy.AutopilotOOBE.json
start "Start-AutopilotOOBE" PowerShell -NoL -C Start-AutopilotOOBE
:: The next line is how you would apply a CustomProfile
REM start "Start-AutopilotOOBE" PowerShell -NoL -C Start-AutopilotOOBE -CustomProfile OSDeploy
:: The next line is how you would configure everything from the command line
REM start "Start-AutopilotOOBE" PowerShell -NoL -C Start-AutopilotOOBE -Title 'OSDeploy Autopilot Registration' -GroupTag Enterprise -GroupTagOptions Development,Enterprise -Assign

exit
'@
$SetCommand | Out-File -FilePath "C:\Windows\Autopilot.cmd" -Encoding ascii -Force


if (-NOT (Test-Path 'C:\Windows\System32\Oobe\Info')) {
        New-Item -Path 'C:\Windows\System32\Oobe\Info' -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

$UnattendXml = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
	<settings pass="specialize">
		<component name="Microsoft-Windows-Deployment"
		           processorArchitecture="amd64"
		           publicKeyToken="31bf3856ad364e35"
		           language="neutral"
		           versionScope="nonSxS"
		           xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
		           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			<RunSynchronous>
				<RunSynchronousCommand wcm:action="add">
					<Order>1</Order>
					<Description>OSDCloud Specialize</Description>
					<Path>Powershell -ExecutionPolicy Bypass -Command Start-OOBEDeploy -Verbose</Path>
				</RunSynchronousCommand>
			</RunSynchronous>
		</component>
	</settings>
</unattend>
'@

$UnattendXml | Out-File -FilePath "C:\Windows\System32\Oobe\Info\Oobe.xml" -Encoding ascii -Force


#================================================
#   PostOS
#   Restart-Computer
#================================================
Restart-Computer