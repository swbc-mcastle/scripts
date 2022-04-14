#!/usr/bin/env bash

# Install PKG from DMG
#
# This script will install a PKG file which is stored in a DMG

# --------------    edit the variables below this line    ----------------

# URL to DMG
source_url="$4"

# Maxdepth PKG (default=1)
maxdepth="$5"

# Temporarily download directory (TMPDIR is not consistant)
download_dir="/private/tmp/"

# ------------------    do not edit below this line    ------------------

# Check if Source DMG is present
if [ -z "${source_url}" ]; then
	echo "URL to DMG is not provided!"
	exit 1
fi

# Use default maxdepth if not defined
if [ -z "${maxdepth}" ]; then
	maxdepth="1"
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
mount_path=$(yes | hdiutil attach -nobrowse "${download_dir}${filename}" | tail -n1 | awk 'BEGIN {FS="\t"}; {print $3}')

# Search the pkg file in the disk image
pkg=$(find "${mount_path}" -name "*.*pkg*" -maxdepth "${maxdepth}")

if [ -n "${pkg}" ]; then
	# Install package
	installer -pkg "${pkg}" -target /

	if [ $? -ne 0 ]; then
		echo "Error installing ${pkg}"
		exit_code="1"
	fi
else
	echo "No package found in ${mount_path}"
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