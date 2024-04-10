#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-08"
위험도="상"
진단_항목="/etc/shadow 파일 소유자 및 권한 설정"
대응방안="/etc/shadow 파일의 소유자가 root이고, 권한이 400 이하인 경우"
shadow_file='/etc/shadow'
현황=()
진단_결과=""

# /etc/shadow 파일 존재 여부 확인
if [ -e "$shadow_file" ]; then
    # 파일 권한 및 소유자 확인
    mode=$(stat -c "%a" "$shadow_file")
    owner_uid=$(stat -c "%u" "$shadow_file")

    # 소유자가 root이고 권한이 400 이하인지 확인
    if [ "$owner_uid" -eq 0 ]; then
        if [ "$mode" -le 400 ]; then
            진단_결과="양호"
            현황+=("/etc/shadow 파일의 소유자가 root이고, 권한이 $mode입니다.")
        else
            진단_결과="취약"
            현황+=("/etc/shadow 파일의 권한이 $mode로 설정되어 있어 취약합니다.")
        fi
    else
        진단_결과="취약"
        현황+=("/etc/shadow 파일의 소유자가 root가 아닙니다.")
    fi
else
    진단_결과="N/A"
    현황+=("/etc/shadow 파일이 없습니다.")
fi

# 결과 출력
echo "{
    \"분류\": \"$분류\",
    \"코드\": \"$코드\",
    \"위험도\": \"$위험도\",
    \"진단 항목\": \"$진단_항목\",
    \"진단 결과\": \"$진단_결과\",
    \"현황\": [$(printf '\"%s\",' "${현황[@]}" | sed 's/,$//')],
    \"대응방안\": \"$대응방안\"
}" | jq .

# jq를 사용하여 JSON 형식으로 출력. jq가 설치되어 있지 않다면, 직접 echo로 출력하거나 다른 방법을 사용해야 함.
