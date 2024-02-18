#!/bin/bash

. function.sh

BAR

CODE [U-22] crond 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하인 경우

[취약]: crontab 명령어 일반사용자 사용가능하거나, crond 관련 파일 640 이상인 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

# Restore backup files
cp /etc/crontab.bak /etc/crontab
cp /etc/cron.hourly.bak /etc/cron.hourly
cp /etc/cron.daily.bak /etc/cron.daily
cp /etc/cron.weekly.bak /etc/cron.weekly
cp /etc/cron.monthly.bak /etc/cron.monthly
cp /etc/cron.allow.bak /etc/cron.allow
cp /etc/cron.deny.bak /etc/cron.deny
cp /var/spool/cron/*.bak /var/spool/cron/*
#cp /var/spool/cron/crontabs/*.bak /var/spool/cron/crontabs/*




# 백업할 원본 파일 배열 설정
files=("/etc/crontab" "/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/etc/cron.allow" "/etc/cron.deny" "/var/spool/cron/*") #/var/spool/cron/crontabs/*

# 백업 디렉터리 설정
# backup_dir="/backup"

# 백업 파일의 접두사 설정
prefix="_backup_"

# 현재 날짜와 시간을 알다
current_time=$(date +%Y%m%d_%H%M%S)

# 각 원본 파일을 반복합니다
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
  # 각 원본 파일을 반복합니다
    # create a new backup file using the current time in the file name
    cp -p "$file" "$file$prefix$current_time"
    # 백업이 성공적으로 생성되었음을 나타내는 메시지 표시
    OK "시스템이 성공적으로 백업되었습니다.: $file$prefix$current_time"
  else
    INFO "$file 을 찾을 수 없습니다"
  fi
done


# --------------------------------------------------------------------------------------


# 원본 파일 배열 설정
files=("/etc/crontab" "/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/etc/cron.allow" "/etc/cron.deny" "/var/spool/cron/*") #/var/spool/cron/crontabs/*

# 백업 디렉터리 설정
# backup_dir="/backup"

# 백업 파일에 대한 접두사 설정
prefix="_backup_"

# 각 원본 파일을 반복합니다
for file in "${files[@]}"; do
  # 각 원본 파일에 대해 가장 오래된 백업 파일 찾기
  oldest_backup=$(ls -t "$file$prefix"* | tail -1)
  if [ -f "$file" ]; then
    #각 원본 파일에 대해 가장 오래된 백업 파일이 있는지 확인
    if [ -f "$oldest_backup" ]; then
      # 가장 오래된 백업 파일을 원래 파일로 복원
      cp -p "$oldest_backup" "$file"
      # 복원이 성공했음을 나타내는 메시지를 표시
      OK "시스템이 성공적으로 원래 상태로 복원되었습니다.: $oldest_backup to $file"
    else
      # 가장 오래된 백업 파일이 없음을 나타내는 메시지를 표시
      WARN "백업 파일을 찾을 수 없습니다. 시스템을 복원할 수 없습니다.: $oldest_backup"
    fi
    else
    INFO "$file 을 찾을 수 없습니다"
    fi
done


cat $result

echo ; echo