#!/bin/bash
# ArkOS Update Script for Anbernic RG351P
# By ridgek
#########
# HELPERS
#########
##
# Calls to update scripts
#
# See UPDATE LOOP below
# If called script exits with code != 0, errorOut is called
#
# @param 0 {string} - Path to called update.sh
# @param 1 {string} - Update Name (eg, "12202020")
# @param 2 {string} - Path to remote GitHub API endoint of RG351P updates folder
# @param 3 {string} - Path to log file
#
# @usage
# /bin/bash "${updateScript}" "${updateName}" "${updateDirUrl}" "${LOG_FILE}"

##
# Cleanup failed update environment and exit script
#
# @param 0 {string} - Path to this script
# @param 1 {num} - Exit Code
# @param 2 {string} - Message
# @param 3 {string} - Path to failed update script
errorOut () {
	local exitCode=${1:-1}
	local msg="${2}"
	local updateScript="${3}"

	# Print message
	if [ ! -z "${msg}" ]; then
		msgbox "${msg}"
	fi

	# Delete failed update script
	if [ ! -z "${updateScript}" ] && [ -f "${updateScript}" ]; then
		rm -v "${updateScript}"
	fi

	# Reset backlight
	echo "${C_BRIGHTNESS}" > /sys/devices/platform/backlight/backlight/backlight/brightness

	exit ${exitCode}
}

###########
# PREFLIGHT
###########
# Check for curl dependency
if ! curl --version &> /dev/null; then
	sudo apt update && sudo apt install curl -y || errorOut 1 "Error: Could not install update dependency: curl" "${0}"
fi

# Check for jq dependency for parsing GitHub API responses
if ! jq --version &> /dev/null; then
	sudo apt update && sudo apt install jq -y || errorOut 1 "Error: Could not install update dependency: jq" "${0}"
fi

# Get list of available updates from GitHub repo
# @todo use production url
# readonly UPDATES=($(curl -s "https://api.github.com/repos/christianhaitian/arkos/contents/updates/RG351P" | jq -r '.[] | .name'))
readonly UPDATES=($(curl -s "https://api.github.com/repos/ridgekuhn/arkos/contents/updates/RG351P?ref=updaterefactor" | jq -r '.[] | .name'))

if [ $? != 0 ] || [ -z "${UPDATES}" ]; then
	errorOut 1 "Error: Could not connect to update server" "${0}"
fi

# Set script globals
readonly WORKINGDIR="/home/ark"
readonly UPDATELOCKDIR="/home/ark/.config"
readonly LATESTUPDATE="${UPDATES[${#UPDATES[@]} - 1]}"
readonly LOG_FILE="${WORKINGDIR}/update${LATESTUPDATE}.log"
readonly C_BRIGHTNESS="$(cat /sys/devices/platform/backlight/backlight/backlight/brightness)"

# Exit if latest update already applied
if [ -f "${UPDATELOCKDIR}/.update${LATESTUPDATE}" ]; then
	errorOut 187 "No more updates available.  Check back later." "${0}"
fi

# Remove conflicting log file
if [ -f "${LOG_FILE}" ]; then
	rm "${LOG_FILE}"
fi

# Lighten up the mood (set backlight to max)
echo 255 > /sys/devices/platform/backlight/backlight/backlight/brightness

#############
# UPDATE LOOP
#############
# Begin log file
touch "${LOG_FILE}"

# Open new tty and update
sudo chmod 666 /dev/tty1
tail -f "${LOG_FILE}" >> /dev/tty1 &

for updateName in "${UPDATES[@]}"; do
	# Get legacy update name (MMDDYYYY format)
	legacyName=$([ ${updateName:9:1} == "0" ] && echo "${updateName:4:4}${updateName:0:4}" || echo "${updateName:4:4}${updateName:0:4}-${updateName:9:1}")

	# Check if update has already been applied
	if [ -f "${UPDATELOCKDIR}/.update${updateName}" ] || [ -f "${UPDATELOCKDIR}/.update${legacyName}" ]; then
		printf "\nUpdate ${updateName} already applied. Skipping...\n" | tee -a "${LOG_FILE}"
		continue
	fi

	# @todo use production URL
	# updateDirUrl="https://raw.githubusercontent.com/christianhaitian/arkos/main/updates/RG351P"
	updateDirUrl="https://raw.githubusercontent.com/ridgekuhn/arkos/updaterefactor/updates/RG351P"
	scriptUrl="${updateDirUrl}/${updateName}/update.sh"
	updateScript="${WORKINGDIR}/${updateName}.sh"

	curl -s "${scriptUrl}" -o "${updateScript}"

	# Check for curl error or downloaded file is actually 404 response from GitHub API
	if [ $? != 0 ] || grep -q "404" "${updateScript}"; then
		errorOut 1 "Error: Could not get update script from ${scriptUrl}" ${updateScript}
	fi

	# Grant execute permission and run script
	chmod a+x "${updateScript}"
	printf "\nApplying update ${updateName}...\n" | tee -a "${LOG_FILE}"
	/bin/bash "${updateScript}" "${updateName}" "${updateDirUrl}" "${LOG_FILE}"

	if [ $? != 0 ]; then
		errorOut $? "Error: Update ${updateName} could not be applied" ${updateScript}
	fi

	# Success! Remove updateScript and set lock file
	if rm ${updateScript} && touch "${UPDATELOCKDIR}/.update${updateName}"; then
		printf "\nSuccess: Update ${updateName} successfully applied\n" | tee -a "${LOG_FILE}"
	fi
done

##########
# TEARDOWN
##########
# Remove local update script
rm -v -- "$0" | tee -a "$LOG_FILE"

# Close update terminal
printf "\033c" >> /dev/tty1

# Reset backlight
echo "${C_BRIGHTNESS}" > /sys/devices/platform/backlight/backlight/backlight/brightness

printf "\nArkOS has been updated to ${LATESTUPDATE}\n" | tee -a "${LOG_FILE}"

msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."

# @todo remove this
exit

# @todo uncomment this
# sudo reboot

# @todo uncomment this
# exit 187
