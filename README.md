rsync-backup
=========================

The `rsync-backup` is a bash script that makes daily backups. If you wish to get snapshot of a directory in a past date, all you have to do is to find the folder corresponding to that date. The backups use hard-links to reduce the disk usage.

Directory Structure
---------------------------------------

The daily backups are stored in this directory structure:

```text
RSYNC_DIR
	LOCAL_MACHINE
		HOME
			2015-04-03
				FULL
				REMOVED-07H00
				REMOVED-20H00
			2015-04-06
				FULL
				REMOVED-19H00
			LAST (2015-04-06)
		PHOTO
			2015-03-29
				FULL
			2015-04-02
				FULL
			LAST (2015-04-02)
		(...)
```

There are some special directories in that strucuture:

* LAST: a symbolic link to the directory of the last backup;
* FULL: the directory that contains the full backup of a day;
* REMOVED-TIME: The directory that mantains the files that where removed.

Script arguments
-------------------------------------------

The `rsync-backup.sh` needs three parameters in this order:
	- MACHINE: the machine name or IP (localhost, my-pc, mywifes-pc, 192.168.1.12, etc)
	- REPOSITORY: the repository name (just an alias for the PATH)
	- PATH: The full path of the folder that will be backed up daily

*Example 1*: make backups of the "/home" folder of "my-pc". The repository name (alias) will be "HOME".

```bash
rsync-backup "my-pc" "HOME" "/home"
```

*Example 2*: make backups of the photo's folder of "mywifes-pc". The repository name will be "PHOTO".

```bash
rsync-backup "my-wifes" "PHOTO" "/mnt/sdb1/Photo"
```

*Example 2*: make backups of the music folder of the machine "192.168.0.12". The repository name will be "MUSIC".

```bash
rsync-backup "192.168.0.12" "MUSIC" "/mnt/sdb1/Music"
```

How to install
-------------------------------------------

* Create a system user to run the script:

```bash
useradd --system --create-home rsync-backup
```

* Copy the scripts `rsync-backup.sh` and `rsync-backup-job.sh` the home folder of the new user:

```bash
cp PATH/TO/rsync-bckup.sh /home/rsync-backup/rsync-backup.sh
cp PATH/TO/rsync-backup-job.sh /home/rsync-backup/rsync-backup-job.sh
```

* Open the file `/home/rsync-backup/rsync-backup.sh` and set the parameter `RSYNC_DIR`. This parameter informs the folder where all the backups will be kept.

```bash
(..)
RSYNC_DIR="/PATH/TO/rsync-backup"
(..)
```

* Open the file `/home/rsync-backup/rsync-backup-job.sh` and insert lines in the functon `main` like these below. See the section "Script arguments":

```text
 # EXAMPLES
run_job "/home/rsync-backup/rsync-backup.sh  <LOCALHOST>     HOME   /home;"
run_job "/home/rsync-backup/rsync-backup.sh  <REMOTEHOST_1>  PHOTO  /mnt/sdb1/Photo;"
run_job "/home/rsync-backup/rsync-backup.sh  <REMOTEHOST_2>  MUSIC  /mnt/sdb1/Music;"
```

* Open the cron table.

```bash
crontab -­e
```

* Insert this line in the cron table, save and close.

```text
0 * * * * /bin/bash /home/rsync-backup/rsync-backup-job.sh &>> /home/rsync-backup/rsync-backup-job.log
```

* Wait the first backup to begin in the next hour.

How to backup direcories from other machines
-------------------------------------------

If you wish to backup folders from other computers of your home network, you can do it using SSH. These are the steps:

* Login with the `rsync-backup` user:

```bash
sudo -i -u rsync-backup
```

* Create a SSH key:

```bash
ssh-keygen ­-t rsa -C "rsync-backup"
```

* Copy the generated file `id_rsa.pub` into the folder `/home/rsync-backup/.ssh/authorized_keys` of the other machines in your home network.


