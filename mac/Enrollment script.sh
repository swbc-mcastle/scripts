#!/usr/bin/env bash

# Enrollment Complete
#
#
#
# Run policies to make sure everything is installed after enrollment. Enrollment
# Complete makes use of DEPNotify which will show the user the progress.
#
# Requirements: DEPNotify https://gitlab.com/Mactroll/DEPNotify

# --------------    edit the variables below this line    ----------------

# Enable debugging
#set -x

# Exit on error
#set -e

# Dry run
dry_run=false

# Jamf Pro triggers in order to execute before logging in.
triggers_before=(
    "install_dockutil"
    "set_computer_name"
    "create_local_admin"
)

# Jamf Pro triggers in order to execute when the user is logged in and text to show in DEPNotify.
triggers_depnotify=(
	"install_google_chrome,Installing Google Chrome..."
    "install_microsoft_office,Installing Microsoft Office 365..."
	"install_microsoft_teams,Installing Microsoft Teams..."
    "set_default_dock,Configuring Dock items..."
	"enable_filevault,Enabling Disk Encryption..."
)

# Jamf Pro triggers in order to execute at the end of the enrollment.
triggers_after=(
)

# DEPNotify app location
depnotify="/Applications/Utilities/DEPNotify.app"

# DEPNotify fullscreen
depnotify_fullscreen=false

# DEPNotify default control file
depnotify_control_file="/var/tmp/depnotify.log"

# DEPNotify enrollment heading messsage. Leave empty to use default text.
depnotify_window_title="Setting up your Mac..."

# DEPNotify enrollment main text. Leave empty to use default text.
depnotify_main_text="Please wait for the installation process to complete. This process will take several minutes. A message will be shown when the installation is completed.\n\nDo not close the display and do not disconnect from the network during installation!"

# DEPNotify enrollment enable FileVault messsage
depnotify_main_text_filevault_restart="Your Mac is now finished with initial setup and configuration! Please restart your Mac to enable disk encryption."

# DEPNotify enrollment complete title
depnotify_main_titel_complete="Your Mac is ready!"

# DEPNotify enrollment complete messsage
depnotify_main_text_complete="Your Mac is now finished with initial setup and configuration! Additional software can be found in Self Service."

# DEPNotify enrollment status start messsage
depnotify_status_start="Starting setup..."

# DEPNotify enrollment status completing messsage
depnotify_status_completing="Completing setup..."

# DEPNotify Self Service Branding. If false use logos below.
depnotify_self_service_branding=false

# DEPNotify logo light mode
depnotify_image_light_mode="/private/tmp/depnotify_logo.png"

# DEPNotify logo light mode complete
depnotify_image_light_mode_complete="/private/tmp/depnotify_logo.png"

# DEPNotify logo dark mode
depnotify_image_dark_mode="${depnotify_image_light_mode}"

# DEPNotify logo dark mode complete
depnotify_image_dark_mode_complete="${depnotify_image_light_mode_complete}"

# ------------------    do not edit below this line    ------------------

# Check for dry run
if [ "${dry_run}" = true ]; then
	echo "Starting dry run..."
	dry_run="echo"
else
	dry_run=""
fi

# Prevent the system from sleeping
${dry_run} caffeinate -d -i -m -s -u &

# Flush the policy history on the Jamf Pro server
${dry_run} jamf flushPolicyHistory

# Cleanup current DEPNotify control file
rm -f "${depnotify_control_file}"

# Count the amount of trigger for the progress bar in DEPNotify
depnotify_determinate="$((${#triggers_depnotify[@]}+3))"

# Check for event that needs to be installed before we show DEPNotify
if [ ${#triggers_before[@]} -gt 0 ]; then
	for trigger in ${triggers_before[@]}; do
		# Run Jamf Pro trigger
		${dry_run} jamf policy -event ${trigger} -forceNoRecon
	done
fi

while pgrep -x "Setup Assistant" &> /dev/null; do
	echo "Setup Assistant still running..."
	sleep 1
done

# Wait for the Dock
while ! pgrep -x "Dock" &> /dev/null; do
	echo "Waiting for Dock..."
	sleep 1
done

# Get the username of the currently logged in user
username=$(stat -f %Su /dev/console)
echo "Current logged in user: ${username}"

# Get the username ID
uid=$(id -u "${username}")
echo "Current logged in uid: ${uid}"

# Check if DEPNotify should use Self Service Branding
if [ "${depnotify_self_service_branding}" = true ]; then
	# Get the app name in case it's renamed
	self_service_app_path=$(defaults read "/Library/Preferences/com.jamfsoftware.jamf.plist" self_service_app_path)

	# Location of the Self Service Branding icon
	depnotify_self_service_branding_logo="/Users/${username}/Library/Application Support/com.jamfsoftware.selfservice.mac/Documents/Images/brandingimage.png"

	# If Self Branding Image is not present open Self Service
	if [ ! -f "${depnotify_self_service_branding_logo}" ]; then
		# Open Self Service (hidden)
		launchctl asuser ${uid} open "${self_service_app_path}" -j
	fi

	# Wait for Self Service Branding to complete
	while [ ! -f "${depnotify_self_service_branding_logo}" ]; do
		echo "Waiting for Self Service Branding to complete..."
		sleep 1
	done

	# Quit Self Service
	kill -9 $(ps -ax | grep -i "${self_service_app_path}" | head -n 1 | awk '{ print $1 }') 2> /dev/null

	# Set images
	depnotify_image="${depnotify_self_service_branding_logo}"
	depnotify_image_complete="${depnotify_self_service_branding_logo}"
else
	# Read user's appearance mode
	appearance_mode=$(launchctl asuser ${uid} defaults read -g AppleInterfaceStyle)

	if [ "${appearance_mode}" == "Dark" ]; then
		# Set images for dark mode
		depnotify_image="${depnotify_image_dark_mode}"
		depnotify_image_complete="${depnotify_image_dark_mode_complete}"
	else
		# Set images for light mode
		depnotify_image="${depnotify_image_light_mode}"
		depnotify_image_complete="${depnotify_image_light_mode_complete}"
	fi
fi

# DEPNotify image
echo "Command: Image: ${depnotify_image}" >> "${depnotify_control_file}"

# Check if we need to set a custom title
if [ -n "${depnotify_window_title}" ]; then
	echo "Command: MainTitle: ${depnotify_window_title}" >> "${depnotify_control_file}"
fi

# Check if we need to set a custom main text
if [ -n "${depnotify_main_text}" ]; then
	echo "Command: MainText: ${depnotify_main_text}" >> "${depnotify_control_file}"
fi

# The the amount of steps in the progress bar
echo "Command: Determinate: ${depnotify_determinate}" >> "${depnotify_control_file}"

# Check if DEPNotify needs to run in full screen
if [ "${depnotify_fullscreen}" = true ]; then
	depnotify_param_fullscreen="-fullScreen"
fi

# Show progress message
echo "Status: ${depnotify_status_start}" >> "${depnotify_control_file}"

# Launch DEPNotify as user
launchctl asuser ${uid} "${depnotify}/Contents/MacOS/DEPNotify" ${depnotify_param_fullscreen} -path ${depnotify_control_file} &

sleep 3

for trigger in "${triggers_depnotify[@]}"; do
	# Show status in DEPNotify
	echo "Status: $(echo ${trigger} | cut -d ',' -f2)" >> ${depnotify_control_file}
	# Run Jamf Pro trigger
	${dry_run} jamf policy -event $(echo ${trigger} | cut -d ',' -f1) -forceNoRecon
	sleep 1
done

# Write a placeholder so we can track if the enrollment has completed
touch "/var/db/.JamfEnrollmentComplete"

# Show status in DEPNotify
echo "Status: ${depnotify_status_completing}" >> ${depnotify_control_file}
# Recon to make sure no unnecessary policies run again at check-in
${dry_run} jamf recon
# Make sure we run all policies without recon
${dry_run} jamf policy -forceNoRecon
${dry_run} jamf policy -forceNoRecon
${dry_run} jamf policy -forceNoRecon
# Recon
${dry_run} jamf recon

# Done
echo "Status: " >> ${depnotify_control_file}
echo "Command: MainTitle: ${depnotify_main_titel_complete}" >> "${depnotify_control_file}"
echo "Command: Image: ${depnotify_image_complete}" >> "${depnotify_control_file}"
# Force DEPNotify to the front
echo "Command: WindowStyle: Activate" >> "${depnotify_control_file}"

# Check for event that needs to run at the end of the enrollment
if [ ${#triggers_after[@]} -gt 0 ]; then
	for trigger in ${triggers_after[@]}; do
		# Run Jamf Pro trigger
		${dry_run} jamf policy -event ${trigger}
	done
fi

# Check to see if FileVault Deferred enablement is active
filevault_status=$(fdesetup status | grep "Deferred" | grep -o "active")

# Show restart message if FileVault need to be enabled
if [ "${filevault_status}" = "active" ]; then
	echo "Command: MainText: ${depnotify_main_text_filevault_restart}" >> "${depnotify_control_file}"
	echo "Command: ContinueButtonRestart: Restart" >> "${depnotify_control_file}"
else
	echo "Command: MainText: ${depnotify_main_text_complete}" >> "${depnotify_control_file}"
	echo "Command: ContinueButton: Done" >> "${depnotify_control_file}"
fi

# Wait for DEPNotify to be closed before we cleanup
while pgrep -x "DEPNotify" &> /dev/null; do
	echo "DEPNotify is still active..."
	sleep 3
done

# Remove DEPNotify
${dry_run} rm -fr "${depnotify}"
rm -f "${depnotify_control_file}"