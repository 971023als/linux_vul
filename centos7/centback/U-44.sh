#!/bin/bash

. function.sh

BAR

CODE [U-44] root 이외의 UID가 ‘0’ 금지

cat << EOF >> $result

[양호]: root 계정과 동일한 UID를 갖는 계정이 존재하지 않는 경우

[취약]: root 계정과 동일한 UID를 갖는 계정이 존재하는 경우

EOF

BAR

# 현재 날짜 및 시간 저장
current_date_time=$(date +"%Y-%m-%d %T")

# Get the backup file name
backup_file_name=`ls /etc/passwd_* | tail -n 1`

# 백업 파일 이름 가져오기
if [ -f "$backup_file_name" ]; then
  # 백업에서 /etc/passwd 파일 복원
  cp $backup_file_name /etc/passwd
else
  OK "백업 파일을 찾을 수 없습니다."
fi


cat $result

echo ; echo