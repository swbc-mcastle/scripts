# Copy the .exe into C:\Windows\temp, run script using the filename of the installer with the hostname of the target computer
# e.g.: "exeinstall pgadmin4-6.8-x64.exe IT-5CG90966XV"

$RemoteInstallPath = 'c$\Windows\Temp'
$LocalInstallPath = 'C:\Windows\Temp'
$InstallFile = 'pgadmin4-6.8-x64.exe'
$RemoteHost = 'IT-5CG91722HS'
# if file is located on remote host:

#Invoke-Command -ComputerName $RemoteHost -ScriptBlock {
#    c:\software\installer.exe /silent
#}
# if file is located on local host:
#Invoke-Command -ComputerName $RemoteHost -ScriptBlock { 
#    Start-Process c:\windows\temp\$Installer -ArgumentList '/silent' -Wait
#}

#For remote hosts
Copy-Item -Path $LocalInstallPath\$InstallFile -Destination "\\$RemoteHost\c$\Windows\Temp\Installer.exe"
Invoke-Command -ComputerName $RemoteHost -ScriptBlock {
    c:\windows\temp\Installer.exe /verysilent /allusers /nocancel /suppressmsgboxes /norestart /nocloseapplications /type=typical
}