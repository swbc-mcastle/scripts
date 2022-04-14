#!/usr/bin/env bash

# Install macOS Installer
#
# Script to start macOS Installer using startosinstall. Requires macOS High
# Sierra 10.13.4 or higher.
#
# https://support.apple.com/en-us/HT208020
# https://support.apple.com/en-us/HT208488

# --------------    edit the variables below this line    ----------------

# Enable debugging
#set -x

# Exit on error
#set -e

# Location of the macOS installer app e.g. "/Applications/Install macOS Mojave.app".
installer="$4"

# When "eraseinstall" (without quotes) is gives as parameter 5 we will erase and install the AFPS Volume. Available since macOS 10.13.4.
eraseinstall="$5"

# The "preservecontainer" (without quotes) is gives as parameter 6 we will keep all volumes in the APFS container. Available since macOS Mojave 10.14.
preservecontainer="$6"

# ------------------    do not edit below this line    -------------------

# Make sure this macOS Installer has startosinstall
if [ ! -f "${installer}/Contents/Resources/startosinstall" ]; then
	echo "${installer}/Contents/Resources/startosinstall is not available. macOS may already have been upgraded. Exiting..."
	exit 0
fi

# Installer major version
installer_major_verion=$(defaults read "${installer}/Contents/Info.plist" CFBundleShortVersionString | awk -F . '{print $1}')

# Installer minor version
installer_minor_verion=$(defaults read "${installer}/Contents/Info.plist" CFBundleShortVersionString | awk -F . '{print $2}')

# Make sure we are using a supported installer
if [ "${installer_major_verion}" -le "13" ] && [ "${installer_minor_verion}" -lt "4" ]; then
	echo "macOS Installer ${installer_major_verion}.${installer_minor_verion} is not supported. Exiting."
	exit 1
fi

# Check if we need to erase the volume
if [ "${eraseinstall}" == "eraseinstall" ]; then
	# Check if APFS container is present
	apfs_container=$(diskutil list | grep "Apple_APFS")

	if [ -n "${apfs_container}" ]; then
		if [ "${preservecontainer}" == "preservecontainer" ]; then
			# Make sure we are using the macOS 10.14 installer
			if [ "${installer_major_verion}" -lt "14" ]; then
				echo "preservecontainer is not available. Exiting."
				exit 1
			fi

			echo "Erase current volume on the APFS container and install ${installer}"
			"${installer}/Contents/Resources/startosinstall" --nointeraction --agreetolicense --eraseinstall --preservecontainer --newvolumename "Macintosh HD"
		else
			echo "Erase all volumes on the APFS container and install ${installer}"
			if [ "${installer_major_verion}" -ge "14" ]; then
				# --applicationpath is deprecated in macOS 10.14 and greater
				"${installer}/Contents/Resources/startosinstall" --nointeraction --agreetolicense --eraseinstall --newvolumename "Macintosh HD"
			else
				"${installer}/Contents/Resources/startosinstall" --applicationpath "${installer}" --nointeraction --agreetolicense --eraseinstall --newvolumename "Macintosh HD"
			fi
		fi
	else
		echo "APFS container is not available. APFS Container is required in order to erase volumes. Exiting."
		exit 1
	fi
else
	echo "Start installing ${installer}"
	if [ "${installer_major_verion}" -ge "14" ]; then
		# --applicationpath is deprecated in macOS 10.14 and greater
		"${installer}/Contents/Resources/startosinstall" --nointeraction --agreetolicense
	else
		"${installer}/Contents/Resources/startosinstall" --applicationpath "${installer}" --nointeraction --agreetolicense
	fi
fi

# Get the app name in case it's renamed
self_service_app_path=$(defaults read "/Library/Preferences/com.jamfsoftware.jamf.plist" self_service_app_path)

# Quit Self Service
kill -9 $(ps -ax | grep -i "${self_service_app_path}" | head -n 1 | awk '{ print $1 }') 2> /dev/null