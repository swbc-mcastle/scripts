#ADTermUser:

#This tool is designed to assist with the Active Directory portion of a user termination.
#The intent is to produce more efficiency and accuracy when it comes to correctly processing AD Objects
#for user terminations.As a technician is processing a termination ticket, they will be prompted to enter
#specific items such as the date of termination, related ticket number and initials which will then be written
#to the AD object of the user being terminated. The script will also move the object into the terminations OU as
#well as remove many group memberships per the termination process standard procedure.

#Required software dependancies: Powershell, ActiveDirectory module for Powershell
#Required privileges: Unrestricted Execution Policy for Powershell
#Required access to run this script: ADDel_CorpUsers_InfoEdit, IT-INFRA-HD

#Setup software dependancies: "Install-Module ActiveDirectory" "Set-ExecutionPolicy Unrestricted -Scope CurrentUser"

#Imports the Active Directory module for Powershell
Import-Module ActiveDirectory

#Variable: $User - prompt for the SAM account name of the AD user to be terminated
$User = Read-Host -Prompt "Enter SAM Account Name"

#Variable: $Ticket - prompt for TASK ticket number related to the termination (will be entered into AD description field)
$Ticket = Read-Host -Prompt "Enter Related Ticket Number"

#Variable: $Tech - prompt for initials of technician performing the termination tasks (will be entered into AD description field)
$Tech = Read-Host -Prompt "Enter Technician Initials"

#Variable: $Date - prompt for effective date of termination listed in ticket (will be entered into AD description field)
$Date = Read-Host -Prompt "Enter Term Date (YYYYMMDD)"

#Variable: $UserIdentity - retrieves the GUID of AD object bieng moved (in this case the user AD account)
$UserIdentity = (get-aduser -identity $User).ObjectGUID

#Variable: $Group - retrieves the primary group token for "Domain Users" (to ensure it is set as the primary group)
$Group = Get-ADGroup "Domain Users" -properties @("primaryGroupToken")

#Variable: $Desc - Reads the current AD object description in order to retain it and prepend with updated description
$Desc = Get-ADUser $User -Properties Description | Select -ExpandProperty Description

#Variable: $RemGroups - Retrieves list of groups to be removed. Uses the -notmatch comparison operator to filter out groups that should remain
$RemGroups = (Get-ADUser "$User" -prop MemberOf).MemberOf -notmatch 'M365_License_Exchange' -notmatch 'M365_License_OneDrive' -notmatch 'Okta VDI' -notmatch 'Okta VPN'

#This line sets the clipboard to the SAM user name of the terminated account (for convenience purposes)
Set-Clipboard $User

#Deprecated - calls the old termination membership rebort VBS script (no longer in use)
#cscript.exe "\\swbc.local\admins$\HelpDesk\Scripts\TermSGReport.vbs"

#Checks if user account is disabled, if not this line will disable the account
Get-ADUser -Identity $User | Where-Object {$_.Enabled -eq $true} | Disable-ADAccount

#This replaces the old term report VBS Script
Get-ADPrincipalGroupMembership $User | Get-ADGroup -Properties * | Select-Object name, description | Out-File -FilePath "\\swbc.local\admins$\HelpDesk\TermSGRprts\$Date`_$User - Membership.txt"

#sets the primary group to "Domain Users" (This group will not be removed, one primary group must remain in membership for AD user object to exist)
Get-ADUser "$User" | Set-ADUser -replace @{primaryGroupID=$Group.primaryGroupToken}

#Removes term user object from all groups existing within the $RemGroups variable
ForEach-Object {
  $RemGroups | Remove-ADGroupMember -Members $UserIdentity -Confirm:$False
}

#Writes the term date, ticket number and technician initials into the description field of the terminated user AD object
Set-ADUser $User -Description "Terminated`_$Date`_$Ticket`_$Tech`_$Desc"

#Moves the terminated user AD object into the terms OU
Move-ADObject -Identity $UserIdentity -TargetPath "OU=Users - Terminated,OU=Corp,DC=swbc,DC=local"

Write-Output "Check \\swbc.local\admins$\HelpDesk\TermSGRprts\ for membership report"
Write-Output "------------------------------------"
Write-Output "-updated AD account and memberships"
Write-Output "-ran term script"
Write-Output "-off board complete"
Write-Output "------------------------------------"
