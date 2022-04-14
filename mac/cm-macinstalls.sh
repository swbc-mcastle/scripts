#!/bin/bash

#Create directory to mount shared folder
sudo mkdir /Volumes/Software

#Create temp directory to store installers
sudo mkdir /tmp/dsinstalls

#Mount Helpdesk SMB Shared folder
sudo mount -t smbfs //p-nasemcsa1-smb/Admins$/Helpdesk/Software /Volumes/Software

#Mount .dmg images
sudo hdiutil attach /Volumes/Software/'Mac Software 2020'/'Cisco AnyConnect 4.10'/anyconnect-macos-4.10.03104-predeploy-k9.dmg
sudo hdiutil attach /Volumes/Software/'Mac Software 2020'/FireEye/IMAGE_HX_AGENT_OSX_32.30.13.dmg
sudo hdiutil attach /Volumes/Software/'Mac Software 2020'/Absolute/AbsoluteAgent7.3-203197.dmg
sudo hdiutil attach /Volumes/Software/'Mac Software 2020'/'Symantec WSS Agent'/MacWSSAgentInstaller-7.4.2.15577.dmg
sudo hdiutil attach /Volumes/Software/'Mac Software 2020'/'Google Chrome'/googlechrome.dmg
sudo hdiutil attach /Volumes/Software/'Mac Software 2020'/VMware/VMware-Horizon-Client-5.5.3-18642617.dmg
sudo hdiutil attach /Volumes/Software/'Mac Software 2020'/'SCCM Client'/pma_agent.dmg

#Copy installers to local filesystem
sudo cp /Volumes/Software/'Mac Software 2020'/'MS Office 365'/Microsoft_Office_16.57.22011101_BusinessPro_Installer.pkg /tmp/dsinstalls/
sudo cp /Volumes/Software/'Mac Software 2020'/'Microsoft Intune Portal'/CompanyPortal-Installer.pkg /tmp/dsinstalls/
sudo cp /Volumes/Software/'Mac Software 2020'/'Trend Apex'/tmsminstall.zip /tmp/dsinstalls/
sudo cp /Volumes/'Parallels Mac Management for Microsoft SCCM'/'Parallels Mac Management for Microsoft SCCM.pkg' /tmp/dsinstalls
sudo cp /Volumes/AbsoluteAgent7.3-203197/AbsoluteAgent7.3.pkg /tmp/dsinstalls/
sudo cp /Volumes/'AnyConnect 4.10.03104'/AnyConnect.pkg /tmp/dsinstalls/
sudo cp /Volumes/'FireEye Agent'/xagtSetup_32.30.13.pkg /tmp/dsinstalls/
sudo cp /Volumes/'Symantec WSS Agent'/'Symantec WSS Agent 7.4.2.15577.pkg' /tmp/dsinstalls/
sudo cp -R /Volumes/'Google Chrome'/'Google Chrome.app'/Contents/MacOs/'Google Chrome' /Applications
sudo cp -R /Volumes/'VMware Horizon Client'/'VMware Horizon Client.app' /Applications

#Extract compressed files
sudo unzip /tmp/dsinstalls/tmsminstall.zip -d /tmp/dsinstalls/

#Install packages
sudo installer -package /tmp/dsinstalls/AnyConnect.pkg -target / -verboseR
sudo installer -package /tmp/dsinstalls/xagtSetup_32.30.13.pkg -target / -verboseR
sudo installer -package /tmp/dsinstalls/CompanyPortal-Installer.pkg -target / -verboseR
sudo installer -package /tmp/dsinstalls/'Symantec WSS Agent 7.4.2.15577.pkg' -target / -verboseR
sudo installer -package /tmp/dsinstalls/AbsoluteAgent7.3.pkg -target / -verboseR
sudo installer -package /tmp/dsinstalls/Microsoft_Office_16.57.22011101_BusinessPro_Installer.pkg -target / -verboseR
sudo installer -package /tmp/dsinstalls/tmsminstall/tmsminstall.pkg -target / -verboseR
sudo installer -package /tmp/dsinstalls/'Parallels Mac Management for Microsoft SCCM.pkg' -target / -verboseR

#unmount application images
sudo hdiutil detach -force /Volumes/AbsoluteAgent7.3-203197
sudo hdiutil detach -force /Volumes/'AnyConnect 4.10.03104'
sudo hdiutil detach -force /Volumes/'FireEye Agent'
sudo hdiutil detach -force /Volumes/'Symantec WSS Agent'
sudo hdiutil detach -force /Volumes/'VMware Horizon Client'
sudo hdiutil detach -force /Volumes/'Google Chrome'

#unmount SMB share
sudo umount -f /Volumes/Software

#remove temporary directories
sudo rm -rf /tmp/dsinstalls

#install Homebrew
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

#change ownership of /usr/local to "staff"
sudo chown -R $(whoami):staff /usr/local/*

#install applications with brew
brew install visual-studio-code sublime-text powershell python@3.9 azure-cli node node@16 node@12 n nvm git postman rectangle azure-cli
