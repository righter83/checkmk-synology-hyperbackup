from synology_api import core_backup
import time, datetime, sys

# Info
# https://github.com/righter83/checkmk-synology-hyperbackup
# v2-alpha

# Config
ip=""
port="5000"
user=""
pw=""
error=False
out=""
runtime=86500
ts=time.time()

# Connect to NAS
b = core_backup.Backup(ip, port, user, pw, secure=False, cert_verify=False, dsm_version=7, debug=False, otp_code=None)

# get backup tasks
tasks=b.backup_task_list()
for task in tasks['data']['task_list']:
    id=task["task_id"]
    name=task["name"]

    # get task status
    status=b.backup_task_result(id)
    endtime=status['data']['last_bkp_end_time']
    result=status['data']['last_bkp_result']

    # Check runtime window
    endts=time.mktime(time.strptime(endtime, "%Y/%m/%d %H:%M"))
    duration=ts - endts
    if (duration > runtime):
        out+="Backup {} did not ran inside Backup window\n".format(name)
    elif (result != 'done'):
        error=True
        out+="Backup {} ended at {} with result: {}\n".format(name, endtime, result)
    else:
        out+="Backup {} ended at {} with result: {}\n".format(name, endtime, result)

if (error):
    print("Crit: {}".format(out))
    sys.exit(2)
else:
    print("Ok: {}".format(out))
    sys.exit(0)
