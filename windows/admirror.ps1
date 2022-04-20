#this is a simple AD script that mirrors SG access and OU location from one AD user to another. -MC
#$MirrorAfterUser: source user = the user SAM account that will be read from
#$TargetUser: target user = the user SAM account that will be WRITTEN TO (Changes will be made to this account)
#$Tech: technician initials (this means you, two characters prefferred i.e. "MC") will be written into the AD description field
#$Hiredate: date listed in ticket as new hires start date if ticket is not for a new hire leave blank.


$MirrorAfterUser = Read-Host -Prompt "Enter Source User Name"
$TargetUser = Read-Host -Prompt "Enter Target User Name"
$Tech = Read-Host -Prompt "Enter technician initials"
$HireDate = Read-Host -Prompt "Enter Hire Date (YYYYMMDD)"
$Ticket = Read-Host -Prompt "Enter onboard ticket number"
$Desc = Get-ADUser $TargetUser -Properties Description | Select -ExpandProperty Description
$MirrorAfterDN = (Get-ADUser "$MirrorAfterUser").DistinguishedName
$MoveTarget = (Get-Aduser "$TargetUser").DistinguishedName
$MirrorAfterOU = $MirrorAfterDN.Substring($MirrorAfterDN.IndexOf(',')+1)
$CopyFromUser = Get-ADUser "$MirrorAfterUser" -prop MemberOf
$CopyToUser = Get-ADUser "$TargetUser" -prop MemberOf
$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser
Add-ADGroupMember -identity O365_MFA_Required -Members $CopyToUser
Move-ADObject -Identity $MoveTarget -TargetPath $MirrorAfterOU
Set-ADUser $TargetUser -Description "$HireDate`_$Ticket`_$Tech`_$Desc"
Set-ADAccountPassword -Reset -Identity $TargetUser
