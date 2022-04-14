$Passwd = read-host -AsSecureString -prompt "enter new password"
New-LocalUser -name Temp -Password $Passwd