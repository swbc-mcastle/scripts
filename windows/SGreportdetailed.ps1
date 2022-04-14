$User = $args[0]
Get-ADPrincipalGroupMembership $User | Get-ADGroup -Properties * | select name, description | format-table -autosize | Out-File -FilePath "$HOME\Desktop\$Date`_$User - Membership.txt"
echo "Check $HOME\Desktop for membership report"