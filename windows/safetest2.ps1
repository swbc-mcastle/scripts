$MirrorAfterUser = "mike.castle"
$TargetUser = "swright"
$MirrorAfterDN = (Get-ADUser "$MirrorAfterUser").DistinguishedName
$MoveTarget = (Get-Aduser "$TargetUser").DistinguishedName
$CopyFromUser = Get-ADUser "$MirrorAfterUser" -prop MemberOf
$CopyToUser = Get-ADUser "$TargetUser" -prop MemberOf
#$UserIdentity = (get-aduser -identity $TargetUser).ObjectGUID
#$Users = @{
#    ReferenceObject = ($CopyFromUser.MemberOf)
#    DifferenceObject = ($CopyToUser.MemberOf)
#}
#$RemGroups = compare-object @Users
#ForEach-Object {
#    ($RemGroups).inputobject | Remove-ADGroupMember -Members $UserIdentity -Confirm:$False
#  }

$Users = Compare-Object -ReferenceObject (Get-AdPrincipalGroupMembership $TargetUser | select name | sort-object -Property name) -DifferenceObject (Get-AdPrincipalGroupMembership $MirrorAfterUser | select name | sort-object -Property name) -property name -passthru
$Users | 