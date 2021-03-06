#!/usr/bin/env bash
#
# rsync-backup
# Makes backups of local and remote hosts using rsync.
# 
# Author: Fabio Lima
# Date: 2015-03-28
# 

# Checks if the three parameters are supplied
if [ -n "${1}" -a -n "${2}" -a -n "${3}" ];
then
	SRC_HOST="${1}";
	SRC_REPO="${2}";
	SRC_DIR="${3}";
else
	echo -e "HOW TO USE:\nrsync-backup HOST REPOSITORY PATH";
	exit 1;
fi;

# Default backup directory. See example:
# RSYNC_DIR="/mnt/backup/Automático/rsync-backup";
RSYNC_DIR="/PATH/TO/rsync-backup";


# Default backup user.
RSYNC_USER="rsync-backup";

# Special directories names.
# You can change it if you want.
LAST_LABEL="LAST";
FULL_LABEL="FULL";
REMOVED_LABEL="REMOVED";

DATE=$(date "+%Y-%m-%d");
TIME=$(date "+%Hh%M");

HOST_DIR="${RSYNC_DIR}/${SRC_HOST}";
REPO_DIR="${HOST_DIR}/${SRC_REPO}";
DEST_DIR="${REPO_DIR}/${DATE}";

DEST_FULL_DIR="${DEST_DIR}/${FULL_LABEL}";
DEST_REMOVED_DIR="${DEST_DIR}/${REMOVED_LABEL}-${TIME}";

LAST_DEST_DIR="${REPO_DIR}/${LAST_LABEL}";
LAST_FULL_DIR="${LAST_DEST_DIR}/${FULL_LABEL}";

RSYNC_LOG="${REPO_DIR}/rsync.log";
SCRIPT_LOG="${REPO_DIR}/rsync-backup.log";

# Checks if the source host is the local host.
# If it is a remote host, rsync uses SSH authentication.
if [ "${SRC_HOST}" = "$(hostname)" ];
then
	RSYNC_SSH_LOGIN="";
else
	RSYNC_SSH_LOGIN="${RSYNC_USER}@${SRC_HOST}:";
fi;

# Changes multiple spaces and tabs for single spaces
function fn_single_spaced {
	STR="${1}";
	
	echo "${STR}" | tr -s '\t ' '  ';
}

# Makes a directory if it doesnt exist
function fn_make_dir {
	NEW_DIR="${1}";

	MKDIR_COMMAND=$(fn_single_spaced \
	"mkdir -p \"${NEW_DIR}\";"); 

	if [ ! -d "${NEW_DIR}" ];
	then	
		echo ${MKDIR_COMMAND};
		bash -c "${MKDIR_COMMAND}";
	fi;
}

# Copies files using hard links
function fn_link_copy {
	COPY_SRC="${1}";
	COPY_DEST="${2}";

	COPY_COMMAND=$(fn_single_spaced \
	"cp --archive --link \"${COPY_SRC}/\"* \"${COPY_DEST}\";");

	if [ -n "${COPY_SRC}" -a -d "${COPY_SRC}" ];
	then
		echo ${COPY_COMMAND} &>> "${SCRIPT_LOG}";
		bash -c "${COPY_COMMAND}" &>> "${SCRIPT_LOG}";
	fi;
}

# Removes empty directories.
function fn_remove_empty_dirs {
	DIR="${1}";

	FIND_COMMAND="find \"${DIR}\" -type d -empty -delete;";

	if [ -n "${DIR}" -a -d "${DIR}" ];
	then
		echo ${FIND_COMMAND}  &>> "${SCRIPT_LOG}"; 
		bash -c "${FIND_COMMAND}" &>> "${SCRIPT_LOG}";
	fi;
}

# Checks if there are changes to be transfered
function fn_has_changes {

	RSYNC_COMMAND=$(fn_single_spaced \
	"rsync --dry-run --archive --relative --itemize-changes \
	--cvs-exclude --exclude=\".*\" --exclude=\".*/\" \
	${RSYNC_SSH_LOGIN}\"${SRC_DIR}\" \
	\"${LAST_FULL_DIR}\";");
	
	if [ -d "${LAST_FULL_DIR}" ];
	then
		echo ${RSYNC_COMMAND} &>> "${SCRIPT_LOG}";
		RESULT=$(bash -c "${RSYNC_COMMAND}" );


		if [ -n "${RESULT}" ];
		then
			echo 1;
		else 
			echo 0;
		fi;
	else 
		echo 1;
	fi;
}

# Core function of this script
function fn_rsync_backup {

	RSYNC_COMMAND=$(fn_single_spaced \
	"rsync --archive --relative --itemize-changes \
	--cvs-exclude --exclude=\".*\" --exclude=\".*/\" \
	--compress --verbose --delete --backup \
	--log-file=\"${RSYNC_LOG}\" \
	--backup-dir=\"${DEST_REMOVED_DIR}\" \
	${RSYNC_SSH_LOGIN}\"${SRC_DIR}\" \
	\"${DEST_FULL_DIR}\";");

	SYMLINK_COMMAND=$(fn_single_spaced \
	"ln --symbolic --relative --force --no-dereference \
	\"${DEST_DIR}\" \"${LAST_DEST_DIR}\";");

	# Create destination directories
	fn_make_dir "${DEST_FULL_DIR}" &>> "${SCRIPT_LOG}";
	fn_make_dir "${DEST_REMOVED_DIR}" &>> "${SCRIPT_LOG}";

	# Hard link copy last full directory to new full directory
	fn_link_copy "${LAST_FULL_DIR}" "${DEST_FULL_DIR}";

	# Transfer changes using rsync
	echo ${RSYNC_COMMAND} &>> "${SCRIPT_LOG}";
	bash -c "${RSYNC_COMMAND}" &>> "${SCRIPT_LOG}";

	# Make simbolic link to new full directory 
	echo ${SYMLINK_COMMAND} &>> "${SCRIPT_LOG}";
	bash -c "${SYMLINK_COMMAND}" &>> "${SCRIPT_LOG}";

	# Remove empty directories
	fn_remove_empty_dirs "${DEST_REMOVED_DIR}";

}

function fn_main {

	MK_REPO=$(fn_make_dir "${REPO_DIR}");

	START_DATE=$(date "+%Y-%m-%d %H:%M:%S");
	echo "---------------------------------" >> "${SCRIPT_LOG}";
	echo START SCRIPT: ${START_DATE} >> "${SCRIPT_LOG}";
	echo "---------------------------------" >> "${SCRIPT_LOG}";
	
	if [ -n "${REPO_DIR}" ];
	then
		echo "${MK_REPO}" >> "${SCRIPT_LOG}";
	fi;

	# Starts transfer only if there are chenges
	if [ "$(fn_has_changes)" -eq 1 ];
	then
		fn_rsync_backup;
	else
		echo "No changes." >> "${SCRIPT_LOG}";
	fi; 

	END_DATE=$(date "+%Y-%m-%d %H:%M:%S");
	echo "---------------------------------" >> "${SCRIPT_LOG}";
	echo END SCRIPT: ${END_DATE} >> "${SCRIPT_LOG}";
	echo "---------------------------------" >> "${SCRIPT_LOG}";
	echo -e "\n\n" >> "${SCRIPT_LOG}";
}

fn_main;

