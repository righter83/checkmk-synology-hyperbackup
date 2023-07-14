#!/bin/bash

# Info
# https://github.com/righter83/checkmk-synology-hyperbackup
# v1.0

# config
job_name="Fileserver"
maxSecongsAge="86500" # How old can a backup be
LANG=de_DE.UTF-8 # Locale Settings because of 12 or 24 hr calc
LC_ALL=de_DE.UTF-8

message=$(grep "$job_name" /var/log/messages | grep -w 'with result \[[1]\]' | tail -1)
detail=$(cut -c 92-200 <<< "$message")
timeStamp=$(echo $message | grep -P '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' -o)

if [ -z "$timeStamp" ] 
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
		echo "Fail: Last backup ${diffReadable} h ago!!!!!. Max age: ${maxAgeReadable} h (${detail})"
		exit 2
	fi

	if [ -n "$diffReadable" ]
	then
		echo "OK: Last backup ${diffReadable} h ago. Max age: ${maxAgeReadable} h (${detail})"
		exit 0
	fi
fi
