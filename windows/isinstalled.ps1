$HostName = $args[0]
$SW = $args[1]
Invoke-Command -ComputerName $HostName -ScriptBlock {
((gp HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Match "$SW").Length -gt 0
}