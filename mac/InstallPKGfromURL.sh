#!/usr/bin/env bash

# Install PKG from URL

#
# This script will install a PKG file from a URL

# --------------    edit the variables below this line    ----------------

# URL to PKG
source_url="$4"

# Temporarily download directory (TMPDIR is not consistant)
download_dir="/private/tmp/"

# ------------------    do not edit below this line    ------------------

# Check if Source URL is present
if [ -z "${source_url}" ]; then
	echo "URL to PKG is not provided!"
	exit 1
fi

# Generate UUID for filename
filename="$(uuidgen).pkg"

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

	# Verify PKG
	echo "Verifying ${download_dir}${filename}..."
	installer -pkginfo -pkg "${download_dir}${filename}" &> /dev/null

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

# Install the package
installer -pkg "${download_dir}${filename}" -target /

if [ $? -ne 0 ]; then
	echo "Error installing ${download_dir}${filename}"
	exit_code="1"
fi

# Remove temporarily download
echo "Deleting download..."
rm -fr "${download_dir}${filename}"

# Exit the script
exit ${exit_code}