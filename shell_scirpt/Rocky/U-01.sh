#!/bin/bash

# 결과를 저장할 JSON 형태의 문자열 초기화
results='{
    "분류": "계정관리",
    "코드": "U-01",
    "위험도": "상",
    "진단 항목": "root 계정 원격접속 제한",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "원격 터미널 서비스 사용 시 root 직접 접속을 차단"
}'

# Telnet 서비스 검사
telnet_status=$(grep -E "telnet\s+\d+/tcp" /etc/services)
if [[ $telnet_status ]]; then
    # JSON 형태의 문자열 업데이트
    results=$(jq '.현황 += ["Telnet 서비스 포트가 활성화되어 있습니다."] | .진단 결과 = "취약"' <<< "$results")
fi

# SSH 서비스 검사
root_login_restricted=true
sshd_configs=$(find /etc/ssh -name 'sshd_config')

for sshd_config in $sshd_configs; do
    if grep -Eq 'PermitRootLogin\s+(yes|without-password)' "$sshd_config" && ! grep -Eq 'PermitRootLogin\s+(no|prohibit-password|forced-commands-only)' "$sshd_config"; then
        root_login_restricted=false
        break
    fi
done

if [[ $root_login_restricted == false ]]; then
    results=$(jq '.현황 += ["SSH 서비스에서 root 계정의 원격 접속이 허용되고 있습니다."] | .진단 결과 = "취약"' <<< "$results")
else
    results=$(jq '.현황 += ["SSH 서비스에서 root 계정의 원격 접속이 제한되어 있습니다."]' <<< "$results")
fi

# 결과 출력
echo $results | jq .

