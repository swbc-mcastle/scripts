#this is a simple AD script that mirrors SG access and OU location from one AD user to another. -MC

# source user = the user SAM account that will be read from
$MirrorAfterUser = Read-Host -Prompt "Enter Source User Name"

# target user = the user SAM account that will be WRITTEN TO (Changes will be made to this account)
$TargetUser = Read-Host -Prompt "Enter Target User Name"

# technician initials (two characters prefferred i.e. "MC", will be written into the AD object description field)
$Tech = Read-Host -Prompt "Enter technician initials"

# hire date as shown in related ticket (will be written into the AD object description field)
$HireDate = Read-Host -Prompt "Enter Hire Date (YYYYMMDD)"

# enter the REQ# for new hire. (will be written into the AD object description field)
$Ticket = Read-Host -Prompt "Enter onboard ticket number"

# declare variable for target user AD object description field
$Desc = Get-ADUser $TargetUser -Properties Description | Select -ExpandProperty Description

# this variable gets the distinguished name of source user
$MirrorAfterDN = (Get-ADUser "$MirrorAfterUser").DistinguishedName

# this variable gets the distinguished name of target user
$MoveTarget = (Get-Aduser "$TargetUser").DistinguishedName

# gets the OU that target will be moved into
$MirrorAfterOU = $MirrorAfterDN.Substring($MirrorAfterDN.IndexOf(',')+1)

# gets list of groups from source user
$CopyFromUser = Get-ADUser "$MirrorAfterUser" -prop MemberOf

# gets list of groups (if any) from target user
$CopyToUser = Get-ADUser "$TargetUser" -prop MemberOf

# compares the two group lists so as not to double tap group assignments
$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser

# adds O365_MFA_Required group to target user (this may no longer be needed, feel free to comment out if so)
Add-ADGroupMember -identity O365_MFA_Required -Members $CopyToUser

# moved target user into same OU as source user
Move-ADObject -Identity $MoveTarget -TargetPath $MirrorAfterOU

# writes changes to target user AD object description
Set-ADUser $TargetUser -Description "$HireDate`_$Ticket`_$Tech`_$Desc"

#prompt technician to create new password for user (this step could be further automated with access to the SNOW API)
Set-ADAccountPassword -Reset -Identity $TargetUser
