#!/bin/bash

# crontab 명령어 권한 조정
find /usr/bin/crontab /usr/sbin/crontab /bin/crontab -type f 2>/dev/null | while read crontab_path; do
    # 명령어가 존재하면 권한을 750으로 설정
    if [ -f "$crontab_path" ]; then
        chmod 750 "$crontab_path"
        echo "$crontab_path 명령어의 권한을 750으로 조정했습니다."
    fi
done

# cron 관련 디렉터리 및 파일 권한 조정
cron_paths=(
    "/etc/cron.hourly"
    "/etc/cron.daily"
    "/etc/cron.weekly"
    "/etc/cron.monthly"
    "/var/spool/cron"
    "/var/spool/cron/crontabs"
    "/etc/crontab"
    "/etc/cron.allow"
    "/etc/cron.deny"
)

for path in "${cron_paths[@]}"; do
    if [ -d "$path" ]; then
        # 디렉터리 내 모든 파일의 권한을 640으로 설정
        find "$path" -type f -exec chmod 640 {} \;
        echo "$path 디렉터리 내 파일의 권한을 640으로 조정했습니다."
    elif [ -f "$path" ]; then
        # 단일 파일의 경우 권한을 직접 조정
        chmod 640 "$path"
        echo "$path 파일의 권한을 640으로 조정했습니다."
    fi
done

echo "U-22 cron 관련 파일 및 명령어의 권한 조정 작업이 완료되었습니다."
