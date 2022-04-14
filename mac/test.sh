#! /bin/bash

#set var for temp directory
temp=$TMPDIR$(uuidgen)

#create directory to mount shared folder
mkdir /Volumes/Software

#mount Helpdesk SMB Shared folder
mount -t smbfs //p-nasemcsa1-smb/Admins$/Helpdesk/Software /Volumes/Software

#create temp directory to store installers
mkdir -p $temp/mount

#copy installers to temp directory
curl https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg > $temp/googlechrome.dmg
cp /Volumes/Software/'Mac Software 2020'/'MS Office 365'/Microsoft_Office_16.57.22011101_BusinessPro_Installer.pkg $temp/
cp /Volumes/Software/'Mac Software 2020'/'Microsoft Intune Portal'/CompanyPortal-Installer.pkg $temp/
cp /Volumes/Software/'Mac Software 2020'/'Trend Apex'/tmsminstall.zip $temp/
cp /Volumes/AbsoluteAgent7.3-203197/AbsoluteAgent7.3.pkg $temp/
cp /Volumes/Software/'Mac Software 2020'/'Cisco AnyConnect 4.10'/anyconnect-macos-4.10.03104-predeploy-k9.dmg $temp/
cp /Volumes/Software/'Mac Software 2020'/FireEye/IMAGE_HX_AGENT_OSX_32.30.13.dmg $temp/
cp /Volumes/Software/'Mac Software 2020'/'Symantec WSS Agent'/MacWSSAgentInstaller-7.4.2.15577.dmg $temp/
