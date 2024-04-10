#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-22"
위험도="상"
진단_항목="crond 파일 소유자 및 권한 설정"
대응방안="crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하 권한 설정"
현황=()

# crontab 명령어 권한 검사
crontab_paths=("/usr/bin/crontab" "/usr/sbin/crontab" "/bin/crontab")
for path in "${crontab_paths[@]}"; do
    if [ -e "$path" ]; then
        permission=$(stat -c "%a" "$path")
        if [ "$permission" -gt 750 ]; then
            현황+=("$path 명령어의 권한이 750보다 큽니다.")
            진단_결과="취약"
        fi
        break
    fi
done

# cron 관련 디렉터리 및 파일 검사
cron_paths=("/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/var/spool/cron" "/var/spool/cron/crontabs" "/etc/crontab" "/etc/cron.allow" "/etc/cron.deny")
for cron_path in "${cron_paths[@]}"; do
    if [ -d "$cron_path" ] || [ -f "$cron_path" ]; then
        files=$(find "$cron_path" -type f 2>/dev/null)
        for file in $files; do
            permission=$(stat -c "%a" "$file")
            owner=$(stat -c "%u" "$file")
            if [ "$owner" -ne 0 ] || [ "$permission" -gt 640 ]; then
                현황+=("$file 파일의 소유자(owner)가 root가 아닙니다 또는 권한이 640보다 큽니다.")
                진단_결과="취약"
            fi
        done
    fi
done

# 진단 결과 결정
if [ -z "$진단_결과" ]; then
    진단_결과="양호"
    현황+=("모든 cron 관련 파일 및 명령어가 적절한 권한 설정을 가지고 있습니다.")
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
for item in "${현황[@]}"; do
    echo "$item"
done
