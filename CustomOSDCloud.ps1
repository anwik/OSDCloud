Write-Host  -ForegroundColor Cyan "Installing Windows 10 21H1 Enterprise ..."
Start-Sleep -Seconds 5

#Change Display Resolution for Virtual Machine
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Cyan "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

#Update OSDCloud module
Write-Host  -ForegroundColor Cyan "Updating the OSDCloud module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Cyan "Importing the module"
Import-Module OSD -Force

#Start OSDCloud ZTI without Autopilot.json
Write-Host  -ForegroundColor Cyan "Start OSDCloud with MY Parameters"
Start-OSDCloud -OSLanguage sv-se -OSBuild 21H1 -OSEdition Enterprise -ZTI


#Restart from WinPE
Write-Host  -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
