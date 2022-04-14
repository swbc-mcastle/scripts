$credential = Get-Credential
$psdrive = @{
    Name = "PSDrive"
    PSProvider = "FileSystem"
    Root = "\\swbc.local\admins$\"
    Credential = $credential
}


$EndPoint = $args[0]
$DataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}-{1}.log' -f $file.fullname,$DataStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f $file.fullname)
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)
Invoke-Command -ComputerName $EndPoint -ScriptBlock {
    New-PSDrive @using:psdrive
    Start-Process $EndPoint -ArgumentList $MSIArguments -Wait -NoNewWindow
}