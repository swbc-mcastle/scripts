#!/bin/sh

## this will demote the current user if it is not YOURLOCALADMINUSERNAMEHERE
currentUser=$(ls -l /dev/console | awk '{ print $3 }')
echo "current user is $currentUser"
if [ $currentUser != "YOURLOCALADMINNAMEHERE" ] ; then
IsUserAdmin=$(id -G $currentUser| grep 80)
    if [ -n "$IsUserAdmin" ]; then
      /usr/sbin/dseditgroup -o edit -n /Local/Default -d $currentUser -t "user" "admin"
      exit 0
    else
        echo "$currentUser is not a local admin"
    fi
fi