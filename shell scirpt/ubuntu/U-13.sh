#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-13"
위험도="상"
진단_항목="SUID, SGID 설정 파일 점검"
대응방안="주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있지 않은 경우"
현황=()
진단_결과=""

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
        if [[ $mode = *s* ]]; then
            vulnerable_files+=("$executable")
        fi
    fi
done

if [ ${#vulnerable_files[@]} -gt 0 ]; then
    진단_결과="취약"
    for file in "${vulnerable_files[@]}"; do
        현황+=("$file")
    done
else
    진단_결과="양호"
    현황+=("SUID나 SGID에 대한 설정이 부여된 주요 실행 파일이 없습니다.")
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
echo "현황:"
for item in "${현황[@]}"; do
    echo "- $item"
done
