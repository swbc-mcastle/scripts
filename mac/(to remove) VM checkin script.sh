#!/bin/bash

#------------variables--------------#
LaunchD1=$"Library/LaunchDaemons/com.jamf.software.task.vmrecon.plist"
LaunchD2=$"Library/LaunchDaemons/com.jamf.software.task.vmpolicy.plist"
#-----------------------------------#
#######################################

#Check if auto recon LaunchD allready exists 
if [ ! -f "$LaunchD1"  ]; then
    echo "$LaunchD1 Does not exist. Creating..."
	/usr/local/jamf/bin/jamf scheduledTask -command "/usr/sbin/jamf recon -randomDelaySeconds 300" -name vmrecon -user root -runAtLoad -minute '*/2/'
fi
#Check if Policy LaunchD allready exits
if [ ! -f "$LaunchD2"  ]; then
    echo "$LaunchD2 Does not exist. Creating..."
	/usr/local/jamf/bin/jamf scheduledTask -command "/usr/sbin/jamf policy -randomDelaySeconds 300" -name vmpolicy -user root -runAtLoad -minute '*/2/'
fi	

exit 1