#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-07"
위험도="상"
진단_항목="/etc/passwd 파일 소유자 및 권한 설정"
대응방안="/etc/passwd 파일의 소유자가 root이고, 권한이 644 이하인 경우"
passwd_file='/etc/passwd'
results_file='results.json'
현황=()
진단_결과=""

# /etc/passwd 파일 존재 여부 확인
if [ -e "$passwd_file" ]; then
    # 파일 권한 확인
    mode=$(stat -c "%a" "$passwd_file")
    owner_uid=$(stat -c "%u" "$passwd_file")

    # 소유자가 root인지 확인
    if [ "$owner_uid" -eq 0 ]; then
        # 파일 권한이 644 이하인지 확인
        if [ "$mode" -le 644 ]; then
            진단_결과="양호"
            현황+=("/etc/passwd 파일의 소유자가 root이고, 권한이 $mode입니다.")
        else
            진단_결과="취약"
            현황+=("/etc/passwd 파일의 권한이 $mode로 설정되어 있어 취약합니다.")
        fi
    else
        진단_결과="취약"
        현황+=("/etc/passwd 파일의 소유자가 root가 아닙니다.")
    fi
else
    진단_결과="N/A"
    현황+=("/etc/passwd 파일이 없습니다.")
fi

# 결과 JSON 형식으로 저장
echo "{
    \"분류\": \"$분류\",
    \"코드\": \"$코드\",
    \"위험도\": \"$위험도\",
    \"진단 항목\": \"$진단_항목\",
    \"진단 결과\": \"$진단_결과\",
    \"현황\": [$(printf '\"%s\",' "${현황[@]}" | sed 's/,$//')],
    \"대응방안\": \"$대응방안\"
}" > "$results_file"

# 결과 출력
cat "$results_file"
