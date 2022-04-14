$credential = Get-Credential
$psdrive = @{
    Name = "PSDrive"
    PSProvider = "FileSystem"
    Root = "\\swbc.local\admins$\"
    Credential = $credential
}

$ExecPath = Read-Host -Prompt "Enter installer path:"
$EndPoint = Read-Host -Prompt "Enter Computer Hostname:"
Invoke-Command -ComputerName $EndPoint -ScriptBlock {
    New-PSDrive @using:psdrive
    Start-Process $ExecPath -ArgumentList '/silent' -Wait
}