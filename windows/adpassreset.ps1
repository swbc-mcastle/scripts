$user = $args[0]
Set-ADAccountPassword -reset -identity $user
