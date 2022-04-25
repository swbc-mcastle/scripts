$SourceUser = Read-Host -Prompt "Enter SAM account username of SOURCE"
$TargetUser = Read-Host -Prompt "Enter SAM account username of TARGET"
$Approver = Read-Host -Prompt "Enter SAM account username of approving supervisor"
$Recipient = (get-aduser $Approver).userprincipalname
$Greeting = echo ("Good morning, `n`nIT department policy states that we must receive confirmation from the supervisor or above on the exact groups given to a new or transferring user. Below is a list of security groups and where the groups grant access to (bulleted beneath the group) for your review. The list is based off of the existing user you requested be referenced. Please respond concerning any changes you may want made to the source, as well as authorization to add the listed groups to your target user.`n`nSource being copied: $SourceUser`nTarget being created: $TargetUser")
$Groups = Get-ADPrincipalGroupMembership $SourceUser
$ApproveList = ($Groups).objectGUID | Get-ADGroup -prop * | select name,description | Format-List
$Mailbody = $Greeting,$ApproveList

#$olFolderDrafts = 16
$Outlook = New-Object -ComObject Outlook.Application
$ns = $Outlook.GetNameSpace("MAPI")
$Mail = $Outlook.CreateItem(0)
#$Mail.IsBodyHTML = $True
$Mail.to = $Recipient
$Mail.subject = "Request for Approval"
$Mail.Body = $Mailbody
#$Message.Body = "$Mailbody"
$Mail.save()
$Inspector = $Mail.GetInspector
$Inspector.Display()