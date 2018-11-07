#!/usr/bin/env bash

function fn_date {
	date '+%Y-%m-%d %Hh%Mm%S';
}

function fn_run_task {
	TASK="${1}";
	echo -e "\n${TASK}";
	bash -c "${TASK}";
	echo -e "Interval: $(fn_date)";
}

function fn_main {
	echo "Start: $(fn_date)"

	# EXAMPLES
	# fn_run_task "rsync-backup  <LOCALHOST>     HOME     /home;";
	# fn_run_task "rsync-backup  <REMOTEHOST_1>  FOTOS    /mnt/sdb1/FOTOS;"
	# fn_run_task "rsync-backup  <REMOTEHOST_2>  MUSICAS  /mnt/sdb1/MUSICAS;"

	echo "End:   $(fn_date)"
	echo -e "\n\n";
}

fn_main;
