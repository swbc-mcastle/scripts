$MirrorAfterUser = Read-Host -Prompt "Enter Reference User Name"
$TargetUser = Read-Host -Prompt "Enter Difference User Name"
Compare-Object -ReferenceObject (Get-AdPrincipalGroupMembership $TargetUser | select name | sort-object -Property name) -DifferenceObject (Get-AdPrincipalGroupMembership $MirrorAfterUser | select name | sort-object -Property name) -property name -passthru