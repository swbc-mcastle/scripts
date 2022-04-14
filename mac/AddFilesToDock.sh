#!/usr/bin/env bash

# Add Fileserver to Dock
#
#
# 
# This script will add a fileserver
# shortcut to the Dock

# --------------    edit the variables below this line    ----------------

# Path to fileserver (smb://FQDN/IP)
fileserver="${4}"

# Friendly name in Dock
friendly_name="${5}"

# ------------------    do not edit below this line    ------------------

if [[ -z "${fileserver}" ]]; then
	echo "Parameter 4 is empty, exiting..."
	exit 1
fi

if [[ -z "${friendly_name}" ]]; then
	echo "Parameter 5 is empty, exiting..."
	exit 1
fi

if [[ ! -f /usr/local/bin/dockutil ]]; then
	echo "Dockutil is not installed, exiting..."
	exit 1
fi

# Wait for the Dock
while ! pgrep -x "Dock" >/dev/null 2>&1; do
	echo "Waiting for Dock..."
	sleep 1
done

# Get the username of the currently logged in user
username=$(stat -f %Su /dev/console)

# Add fileserver to Dock
/usr/local/bin/dockutil --add "${fileserver}" --label "${friendly_name}" /Users/"${username}"