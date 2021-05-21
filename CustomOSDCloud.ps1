$OSLanguage = "sv-se"
$OSBuild = "21H1"
$OSEdition "Enterprise"


Write-Host  -ForegroundColor Cyan "Installing Windows 10 $($OSBuild) $($OSEdition) ..."
Start-Sleep -Seconds 5

#Change Display Resolution for Virtual Machine
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Cyan "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

#Install latest OSD module
Write-Host  -ForegroundColor Cyan "Updating the OSD Module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Cyan "Importing the sweet OSD PowerShell Module"
Import-Module OSD -Force

#TODO: Spend the time to write a function to do this and put it here
Write-Host  -ForegroundColor Cyan "Ejecting ISO"
Write-Warning "That didn't work because I haven't coded it yet!"
#Start-Sleep -Seconds 5

#Start OSDCloud ZTI the RIGHT way
Write-Host  -ForegroundColor Cyan "Start OSDCloud with MY Parameters"
Start-OSDCloud -OSLanguage $OSLanguage -OSBuild $OSBuild -OSEdition $OSEdition -ZTI -SkipAutopilot True

# Prepare Autopilot process using audit mode
Write-Host  -ForegroundColor Cyan "Enabling audit mode for Autopilot registration ..."
Use-WindowsUnattend.audit.autopilot

#Restart from WinPE
#Write-Host  -ForegroundColor Cyan "Restarting in 20 seconds!"
#Start-Sleep -Seconds 20
#wpeutil reboot
