#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,solution,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="서비스 관리"
code="U-22"
riskLevel="상"
diagnosisItem="crond 파일 소유자 및 권한 설정"
solution="crontab 명령어 일반사용자 금지 및 cron 관련 파일 640 이하 권한 설정"
diagnosisResult=""
status=""

TMP1=$(basename "$0").log
> $TMP1

cat << EOF >> $TMP1
[양호]: 모든 cron 관련 파일 및 명령어가 적절한 권한 설정을 가지고 있습니다.
[취약]: cron 관련 파일 및 명령어가 부적절한 권한 설정을 가지고 있습니다.
EOF

# Check crontab command permissions
crontab_paths=("/usr/bin/crontab" "/usr/sbin/crontab" "/bin/crontab")
for path in "${crontab_paths[@]}"; do
    if [ -e "$path" ]; then
        permission=$(stat -c "%a" "$path")
        if [ "$permission" -gt 750 ]; then
            diagnosisResult="$path 명령어의 권한이 750보다 큽니다."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
            echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
        fi
        break
    fi
done

# Check cron related directories and files
cron_paths=("/etc/cron.hourly" "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" "/var/spool/cron" "/var/spool/cron/crontabs" "/etc/crontab" "/etc/cron.allow" "/etc/cron.deny")
for cron_path in "${cron_paths[@]}"; do
    if [ -d "$cron_path" ] || [ -f "$cron_path" ]; then
        files=$(find "$cron_path" -type f 2>/dev/null)
        for file in $files; do
            permission=$(stat -c "%a" "$file")
            owner=$(stat -c "%u" "$file")
            if [ "$owner" -ne 0 ] || [ "$permission" -gt 640 ]; then
                diagnosisResult="$file 파일의 소유자(owner)가 root가 아닙니다 또는 권한이 640보다 큽니다."
                status="취약"
                echo "WARN: $diagnosisResult" >> $TMP1
                echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
            fi
        done
    fi
done

# Final check if no vulnerabilities found
if [ -z "$diagnosisResult" ]; then
    diagnosisResult="모든 cron 관련 파일 및 명령어가 적절한 권한 설정을 가지고 있습니다."
    status="양호"
    echo "OK: $diagnosisResult" >> $TMP1
    echo "$category,$code,$riskLevel,$diagnosisItem,$solution,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

cat $TMP1

echo ; echo


# ==== MD OUTPUT (stdout — shell_runner.sh 가 캡처하여 stdout.txt 저장) ====
_md_code="${code:-${CODE:-U-??}}"
_md_category="${category:-}"
_md_risk="${riskLevel:-${severity:-}}"
_md_item="${diagnosisItem:-${check_item:-진단항목}}"
_md_result="${diagnosisResult:-${result:-}}"
_md_status="${status:-${details:-${service:-}}}"
_md_solution="${solution:-${recommendation:-}}"

cat << __MD_EOF__
# ${_md_code}: ${_md_item}

| 항목 | 내용 |
|------|------|
| 분류 | ${_md_category} |
| 코드 | ${_md_code} |
| 위험도 | ${_md_risk} |
| 진단항목 | ${_md_item} |
| 진단결과 | ${_md_result} |
| 현황 | ${_md_status} |
| 대응방안 | ${_md_solution} |
__MD_EOF__
