#!/bin/bash

OUTPUT_CSV="output.csv"

if [ ! -f $OUTPUT_CSV ]; then
echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

category="로그 관리"
code="U-67"
riskLevel="중"
diagnosisItem="로그 디렉터리 소유자 및 권한 설정"

result="양호"
status=""

#########################################
# 로그 디렉터리 후보
#########################################
log_dirs="/var/log /var/adm /var/adm/syslog"

for dir in $log_dirs
do
    if [ -d "$dir" ]; then
        
        for file in $(find $dir -type f 2>/dev/null)
        do
            owner=$(stat -c %U "$file" 2>/dev/null)
            perm=$(stat -c %a "$file" 2>/dev/null)

            # 소유자 root 아닌 경우
            if [ "$owner" != "root" ]; then
                result="취약"
                status="$status | owner_not_root:$file($owner)"
            fi

            # 권한 644 초과 체크
            if [ "$perm" -gt 644 ]; then
                result="취약"
                status="$status | perm_over_644:$file($perm)"
            fi
        done

        status="$status | checked:$dir"
    fi
done

#########################################
# 결과 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$result,\"$status\"" >> $OUTPUT_CSV

cat $OUTPUT_CSV
