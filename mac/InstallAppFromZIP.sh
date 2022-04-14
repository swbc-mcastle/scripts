#!/usr/bin/env bash

# Install App from ZIP
#
# This script will install or update an Application that resists in a ZIP file.

# --------------    edit the variables below this line    ----------------

# URL to ZIP
source_url="$4"

# Destination directory (with trailing slash)
destination_dir="$5"

# Temporarily download directory (TMPDIR is not consistant)
download_dir="/private/tmp/$(date +%s)/"

# ------------------    do not edit below this line    ------------------

# Check if Source URL is present
if [ -z "${source_url}" ]; then
	echo "URL to ZIP is not provided!"
	exit 1
fi

# Use /Applications/ as default directory
if [ -z "${destination_dir}" ]; then
	destination_dir="/Applications/"
fi

# Create temporarily directory
mkdir -p "${download_dir}"

# Generate UUID for filename
filename="$(uuidgen).zip"

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

	# Verify ZIP
	echo "Verifying ${download_dir}${filename}..."
	unzip -qq -t "${download_dir}${filename}"

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

# Extract files to download directory
echo "Extracting ${download_dir}${filename} to ${download_dir}..."
unzip -o -qq "${download_dir}${filename}" -d "${download_dir}"

# Search the app file in the tmp directory
app=$(find "${download_dir}" -name "*.app" -maxdepth 1)

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
	echo "No Application found in ${download_dir}"
	# Generate exit code
	exit_code="1"
fi

# Remove temporarily download
echo "Deleting download..."
rm -fr "${download_dir}${filename}"

# Exit the script
exit ${exit_code}