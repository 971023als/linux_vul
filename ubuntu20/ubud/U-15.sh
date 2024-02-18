#!/bin/bash

. function.sh

BAR

CODE [U-15] world writable 파일 점검 @@ 조치 후 웹 서비스 장애  @@

cat << EOF >> $result

[양호]: 시스템 중요 파일에 world writable 파일이 존재하지 않거나, 존재 시 설정 이유를 확인하고 있는 경우

[취약]: 시스템 중요 파일에 world writable 파일이 존재하나 해당 설정 이유를 확인하고 있지 않는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  


# Create a backup directory
mkdir -p /backup_777_files

# Copy all files with permission 777 to the backup directory
find / -type f -perm 777 -exec cp {} /backup_777_files/ \;

# ---------------------------------------------------------------------

# Restore the original state of the files
find /backup_777_files/ -type f -exec cp {} / \;

INFO "백업완료"

cat $result

echo ; echo