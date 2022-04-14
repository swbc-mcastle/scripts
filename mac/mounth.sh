#! /bin/bash
if [ -d "/Volumes/HDrive" ]
then
   umount "/Volumes/HDrive" && rm -rf "/Volumes/HDrive"
else
   mkdir /Volumes/HDrive && mount -t smbfs //p-appfilehq5-v/dfs_e$/userdata/homedrive/mike.ashton /Volumes/HDrive
fi
chmod 777 /Volumes/HDrive
