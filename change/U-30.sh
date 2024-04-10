#!/bin/bash

# 최신 버전 정보 (이 정보는 정기적으로 확인 및 업데이트 필요)
latest_version="8.17.1"

# Sendmail 버전 확인
if type sendmail > /dev/null 2>&1; then
    sendmail_version=$(sendmail -d0.1 < /dev/null | grep -oP 'Version \K[\d.]+')
    echo "현재 Sendmail 버전: $sendmail_version"
    
    # 버전 비교
    if [ "$sendmail_version" == "$latest_version" ]; then
        echo "Sendmail 버전이 최신입니다."
    else
        echo "Sendmail 버전이 최신이 아닙니다. 최신 버전($latest_version)으로 업데이트 권장."
        # 업데이트 권장 메시지
        echo "업데이트 방법: 시스템의 패키지 관리자를 사용하거나, Sendmail 공식 웹사이트에서 최신 버전을 다운로드하여 업데이트하세요."
    fi
else
    echo "Sendmail이 설치되어 있지 않습니다."
fi
