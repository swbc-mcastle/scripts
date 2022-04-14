$str = $args[0]
Get-ADcomputer -Filter {(userprincipalname -like $str) -or (samAccountName -like $str)} | Format-Table Name,SamAccountName