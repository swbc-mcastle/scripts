$str = $args[0]
Get-ADUser -Filter {(userprincipalname -like $str) -or (samAccountName -like $str)} | Format-Table Name,SamAccountName