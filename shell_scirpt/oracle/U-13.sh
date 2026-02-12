#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "분류,코드,위험도,진단항목,대응방안,진단결과,현황" > $OUTPUT_CSV
fi

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-13"
위험도="상"
진단항목="SUID, SGID 설정 파일 점검"
대응방안="주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있지 않은 경우"
현황=""
진단결과=""

TMP1=$(basename "$0").log
> $TMP1

# 검사할 실행 파일 목록
executables=(
    "/sbin/dump" "/sbin/restore" "/sbin/unix_chkpwd"
    "/usr/bin/at" "/usr/bin/lpq" "/usr/bin/lpq-lpd"
    "/usr/bin/lpr" "/usr/bin/lpr-lpd" "/usr/bin/lprm"
    "/usr/bin/lprm-lpd" "/usr/bin/newgrp" "/usr/sbin/lpc"
    "/usr/sbin/lpc-lpd" "/usr/sbin/traceroute"
)

vulnerable_files=()

for executable in "${executables[@]}"; do
    if [ -f "$executable" ]; then
        mode=$(stat -c "%A" "$executable")
        if [[ $mode == *s* ]]; then
            vulnerable_files+=("$executable")
        fi
    fi
done

if [ ${#vulnerable_files[@]} -gt 0 ]; then
    진단결과="취약"
    현황=$(printf ", %s" "${vulnerable_files[@]}")
    현황=${현황:2}
else
    진단결과="양호"
    현황="SUID나 SGID에 대한 설정이 부여된 주요 실행 파일이 없습니다."
fi

# 결과를 로그 파일에 기록
echo "현황: $현황" >> $TMP1

# CSV 파일에 결과 추가
echo "$분류,$코드,$위험도,$진단항목,$대응방안,$진단결과,$현황" >> $OUTPUT_CSV

# 로그 파일 출력
cat $TMP1

# CSV 파일 출력
echo ; echo
cat $OUTPUT_CSV
