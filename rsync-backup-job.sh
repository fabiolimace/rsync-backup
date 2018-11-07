#!/usr/bin/env bash

function now {
	date '+%Y-%m-%d %Hh%Mm%S';
}

function run_job {
	TASK="${1}";
	echo -e "\n${TASK}";
	bash -c "${TASK}";
	echo -e "Interval: $(now)";
}

function main {
	echo "Start: $(now)"

	# EXAMPLES
	# run_job "/home/rsync-backup/rsync-backup.sh  <LOCALHOST>     HOME     /home;";
	# run_job "/home/rsync-backup/rsync-backup.sh  <REMOTEHOST_1>  PHOTO    /mnt/sdb1/Photo;"
	# run_job "/home/rsync-backup/rsync-backup.sh  <REMOTEHOST_2>  MUSIC    /mnt/sdb1/Music;"

	echo "End:   $(now)"
	echo -e "\n\n";
}

main;
