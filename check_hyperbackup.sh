#!/bin/bash

# Info
# https://github.com/righter83/checkmk-synology-hyperbackup
# v1.3

# config
job_name="Fileserver"
maxSecongsAge="86500" # How old can a backup be
LANG=de_DE.UTF-8 # Locale Settings because of 12 or 24 hr calc
LC_ALL=de_DE.UTF-8

# check version of hyperbackup
hbver=$(/usr/syno/bin/synopkg version HyperBackup)
shortver=${hbver:0:1}${hbver:2:1}
if [ "$shortver" -gt "40" ]
then
        message=$(grep "$job_name" /volume1/@appdata/HyperBackup/log/hyperbackup.log | grep -w 'with result \[1\]' | tail -1)
	# shitty workaround if last log has already been rotated
        message2=$(xzcat /volume1/@appdata/HyperBackup/log/hyperbackup.log.1.xz | grep "$job_name" | grep -w 'with result \[1\]' | tail -1)
else
        message=$(grep "$job_name" /var/log/messages | grep -w 'with result \[[1]\]' | tail -1)
fi

detail=$(cut -c 92-200 <<< "$message")
timeStamp=$(echo $message | grep -P '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' -o)
detail2=$(cut -c 92-200 <<< "$message2")
timeStamp2=$(echo $message2 | grep -P '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' -o)

if [ -z "$timeStamp" ] && [ -z "$timeStamp2" ]
then
  echo "Fail No Backup found  with Name ${job_name}"
	exit 2
else
        backupDate=$(date --date "$timeStamp" +'%s')
	currentDateSeconds=$(date +'%s')
	diff=$(expr $currentDateSeconds - $backupDate)
	diffReadable=$(($diff / 60 / 60))
	maxAgeReadable=$(($maxSecongsAge / 60 / 60))

	returnCode=0
	if [ "$diff" -gt "$maxSecongsAge" ]
	then
		echo "Fail: Last backup ${diffReadable} h ago!!!!!. Max age: ${maxAgeReadable} h (${detail} ${detail2})"
		exit 2
	fi

	if [ -n "$diffReadable" ]
	then
		echo "OK: Last backup ${diffReadable} h ago. Max age: ${maxAgeReadable} h (${detail} ${detail2})"
		exit 0
	fi
fi
