#! /bin/sh

#username of technician performing installs
tech=`ls -la /dev/console | cut -d " " -f 4`

#declare variable for share path
share_path=p-nasemcsa1-smb/Admins$

#declare variable for mount path
mount_path=/Volumes/Admins$

#declare variable for installer directory
swdir=/Volumes/Admins$/HelpDesk/Software/swbc_macstd

#Check if share_path is mounted
isMounted=`mount | grep -c "/Volumes/Admins$"`

#Mount mac standard software directory via SMB if needed
if [ $isMounted == 0 ] ; then
   mkdir $mount_path
   mount -t smbfs //$tech@$share_path $mount_path
fi

#Install packages
installer -package $swdir/'Cisco AnyConnect 4.10'/AnyConnect.pkg -target / -applyChoiceChangesXML /Volumes/swbc_macstandard/config.xml
installer -package $swdir/FireEye/xagtSetup_32.30.13.pkg -target / -verboseR
installer -package $swdir/'Symantec WSS Agent'/'Symantec WSS Agent 7.4.2.15577.pkg' -target / -verboseR
installer -package $swdir/Absolute/AbsoluteAgent7.3.pkg -target / -verboseR
installer -package $swdir/'MS Office 365'/O365.pkg -target / -verboseR

#allow applications through gatekeeper
spctl --add /Applications/TrendMicroSecurity.app
spctl --add /Applications/'VMware Horizon Client.app'
spctl --add /Applications/Cisco/'Cisco AnyConnect Secure Mobility Client.app'

#unmount SMB share
umount -f /Volumes/Admins$
rm -rf /Volumes/Admins$
