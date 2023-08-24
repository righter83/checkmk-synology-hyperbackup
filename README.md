# checkmk-synology-hyperbackup

## Changes

### v2-alpha
Experimented with the API Library https://github.com/N4S4/synology-api. It connects to the Synology API to get the backup results
can be tried with check_hyperbackup_api.py

### v1.1
Addedd version check for HyperBackup. Starting with 4.1 it has a different log location. (not tested on my NAS yet)

### v1.0
inital relase

## Info ##
This scripts is written for CheckMK.
Tested on:
- CheckMK 2.2
- Synology DSM 7.2
- Hyper Backup 4.0

## Install
* Copy the scripty to your Synology NAS and make it excecutable.
```
cd /volume1
wget https://raw.githubusercontent.com/righter83/checkmk-synology-hyperbackup/main/check_hyperbackup.sh
chmod +x check_hyperbackup.sh
```
* Install the SSH Key from CheckMK on your NAS.
* Afterwards you have to configure the Check in CheckMK:
Go to Services -> Other Services and add a "Check via SSH service"
Configure everything for your NAS and the command should be like:
```/volume1/check_hyperbackup.php```

## Config modifications
There is also a check inside which checks if the job was running in a specific time window.
If you run a job daily you should adjust the config variable maxSecondsAge to 86500 -> a little bit higher as one day.
You can also disable this check if you set the runtimecheck variable to False

## Outputs

### OK ###
```
OK: Last backup 2 h ago. Max age: 24 h (Backup task [Local Storage 1] completes with result [1]. Time spent: [576 sec].)
```
### Time to old ###
```
Fail: Last backup 2 h ago!!!!!. Max age: 0 h (Backup task [Local Storage 1] completes with result [1]. Time spent: [576 sec].)
```

### Backup not found ###
```
No Backup found
```
