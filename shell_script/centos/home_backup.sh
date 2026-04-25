#!/bin/bash

LOG=/var/log/backup.log
DAY=$(date +%d)

backup() {
echo
echo "Backup Started: $(date)" 
cd /home
tar czf /backup/home_$(date +%m%d).tar.gz . >/dev/null 2>&1
if [ $? -eq 0 ] ; then
		echo " [ OK ] Backup Suceecss!" 
else
		echo " [ FAIL ] Backup Failed"  
fi
echo "Backup Finished: $(date)"  
echo 
}


if [ $DAY -ge 2 -a $DAY -le 8 ] ; then
		echo "==> check1"
		backup >> $LOG 2>&1
fi

backup >> $LOG 2>&1

#[ $DAY -ge 2 -a $DAY -le 8 ] && backup >> $LOG 2>&1


