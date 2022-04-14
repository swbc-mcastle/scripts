$computername = $args[0]
$InstallerPath = Read-Host -Prompt "Enter full path to installer:"
$session = New-PSSession -ComputerName $computerName
Copy-Item -Path $file -ToSession $session -Destination $InstallerPath

Invoke-Command -Session $session -ScriptBlock {
    c:\windows\temp\installer.exe /silent
}
Remove-PSSession $session