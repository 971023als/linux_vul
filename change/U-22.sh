#!/bin/bash

# crontab 명령어 권한 설정
crontab_paths=("/usr/bin/crontab" "/usr/sbin/crontab" "/bin/crontab")
for path in "${crontab_paths[@]}"; do
    if [ -e "$path" ]; then
        chmod 750 "$path"
        echo "$path 명령어의 권한이 750으로 설정되었습니다."
        break
    fi
done

# cron 관련 디렉터리 및 파일 권한 설정
cron_paths=("/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/var/spool/cron" "/var/spool/cron/crontabs" "/etc/crontab" "/etc/cron.allow" "/etc/cron.deny")
for cron_path in "${cron_paths[@]}"; do
    if [ -d "$cron_path" ] || [ -f "$cron_path" ]; then
        # 디렉터리 권한 설정
        if [ -d "$cron_path" ]; then
            chmod -R 640 "$cron_path"
            chown -R root:root "$cron_path"
            echo "$cron_path 디렉터리 및 내부 파일의 권한이 640으로, 소유자가 root로 설정되었습니다."
        fi
        # 파일 권한 설정
        if [ -f "$cron_path" ]; then
            chmod 640 "$cron_path"
            chown root:root "$cron_path"
            echo "$cron_path 파일의 권한이 640으로, 소유자가 root로 설정되었습니다."
        fi
    fi
done

echo "모든 crontab 관련 파일 및 명령어에 대한 권한 설정 조치가 완료되었습니다."
