#!/usr/bin/env bash

# Install App from DMG
#
# This script will install an Application that resists in a DMG file.

# --------------    edit the variables below this line    ----------------

# URL to DMG
source_url="$4"

# Destination directory (with trailing slash)
destination_dir="$5"

# Temporarily download directory (TMPDIR is not consistant)
download_dir="/private/tmp/"

# ------------------    do not edit below this line    ------------------

# Check if Source URL is present
if [ -z "${source_url}" ]; then
	echo "URL to DMG is not provided!"
	exit 1
fi

# Use /Applications/ as default directory
if [ -z "${destination_dir}" ]; then
	destination_dir="/Applications/"
fi

# Generate UUID for filename
filename="$(uuidgen).dmg"

# Try download three times
for i in {1..3}; do
	# Check if we still have an internet connection
	if ! ping -c 1 8.8.8.8 &> /dev/null; then
		echo "The internet connection appears to be offline. Exiting..."
		exit 0
	fi

	# Download the file with a max timeout of one hour
	echo "Downloading ${source_url} to ${download_dir}${filename}..."
	curl -Ls -m 3600 "${source_url}" > "${download_dir}${filename}"

	# Verify DMG
	echo "Verifying ${download_dir}${filename}..."
	hdiutil verify "${download_dir}${filename}" &> /dev/null

	if [ $? -ne 0 ]; then
		if [ $i -eq 3 ]; then
			echo "Verifying ${download_dir}${filename} failed (attempt $i). Exiting..."
			exit 1
		else
			echo "Verifying ${download_dir}${filename} failed (attempt $i). Download again..."
		fi
	else
		echo "Verifying ${download_dir}${filename} succeeded..."
		break
	fi
done

# Mount DMG and bypassing EULA if present in DMG
echo "Mounting DMG..."
mount_path=$(yes | hdiutil attach -nobrowse "${download_dir}${filename}" | tail -n1 | awk 'BEGIN {FS="\t"}; {print $3}')

# Search the app file in the disk image
app=$(find "${mount_path}" -type d -name "*.app" -maxdepth 1)

if [ -n "${app}" ]; then
	# Name of Application
	app_name=$(basename "${app}")

	# Copy application
	echo "Copying ${app} to ${destination_dir}..."
	rsync -avz --delete "${app}" "${destination_dir}" &> /dev/null

	if [ $? -ne 0 ]; then
		echo "Error copying ${app} to ${destination_dir}"
		exit_code="1"
	fi

	# Remove "Downloaded from Internet" warning
	echo "Removing quarantine attribute..."
	xattr -d -r com.apple.quarantine "${destination_dir}${app_name}"
else
	echo "No application found in ${mount_path}"
	# Generate exit code
	exit_code="1"
fi

# Unmount DMG
echo "Unmounting DMG..."
hdiutil detach "${mount_path}" &> /dev/null

# Remove temporarily download
echo "Deleting download..."
rm -fr "${download_dir}${filename}"

# Exit the script
exit ${exit_code}