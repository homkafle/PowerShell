#RemoteRegistryCheker.ps1 
#Version 1.0
#Author: Hom Kafle
#This Scritpt allows you to read a list of computers (IP or ComputerName) from a text files and get remote registry service information remotely using a provided 
#Credentials.
#
clear
$UserName = Read-Host "Enter User Name:" 
$Password = Read-Host -AsSecureString "Enter Your Password:" 
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $Password 
$computers = Get-Content -Path C:\Script\host.txt
foreach ($computer in $computers) 
{ 
write-host -foregroundcolor green "`nChecking $computer `n"
$service=Get-WMIObject Win32_Service -computer $computer -credential $cred | Where { $_.Name -eq "remoteregistry" } 
$state=$service.State
if($state -eq "Running")
{ 
write-host "'n The remote registry service is running at $computer'n"
echo $computer >> C:\Script\StartedRegistry.txt
}
else
{ 
Write-Host "Remote Registry Service Not started at " $computer "....." -ForegroundColor Red 
echo $computer >> C:\Script\StoppedRegistry.txt 
}
}
$start = Read-Host "`nDo you want to start Remote Registry Services on other hosts: [Y]es/[N]o"
if ($start -eq "Yes" -or $start -eq "Y" -or $start -eq "y" -or $start -eq "yes")
{
Write-Host "`nThe following devices will have remote registry started:`n"
$need = Get-Content -Path C:\Script\StoppedRegistry.txt
foreach ($computer in $need) 
{ 
write-host -foregroundcolor green "`nAttemtping to start remote registry service at $computer `n"
(Get-WMIObject Win32_Service -computer $computer -credential $cred | Where { $_.Name -eq "remoteregistry" }).StartService()
$started=Get-WMIObject Win32_Service -computer $computer -credential $cred | Where { $_.Name -eq "remoteregistry" }
$update=$started.State
if($update -eq "Running")
{
Write-Host "`n Remote Registry Services started successfully."
}

}
}
$start = Read-Host "`nDo you want to Stop Remote Registry Services that just started: [Y]es/[N]o"
if ($start -eq "Yes" -or $start -eq "Y" -or $start -eq "y" -or $start -eq "yes")
{
Write-Host "`nThe following devices will have remote registry stopped:'n"
$need = Get-Content -Path C:\Script\StoppedRegistry.txt
foreach ($computer in $need) 
{ 
write-host -foregroundcolor green "`nAttemtping to stop remote registry service at $computer `n"
(Get-WMIObject Win32_Service -computer $computer -credential $cred | Where { $_.Name -eq "remoteregistry" }).StopService()
$updatedcase=Get-WMIObject Win32_Service -computer $computer -credential $cred | Where { $_.Name -eq "remoteregistry" }
$recent=$updatedcase.State
if($recent -eq "Stopped")
{
Write-Host "`n Remote Registry Services Stopped successfully."
}
}
}
