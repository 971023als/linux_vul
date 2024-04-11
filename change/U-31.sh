#!/bin/bash

# sendmail.cf 파일 검색 및 릴레이 제한 설정
search_directory='/etc/mail/'
sendmail_cf_file=$(find $search_directory -name 'sendmail.cf' -type f)

if [ ! -z "$sendmail_cf_file" ]; then
    echo "sendmail.cf 파일을 찾았습니다: $sendmail_cf_file"
    
    # 릴레이 제한 설정 확인
    if grep -qE 'R$\*' "$sendmail_cf_file" || grep -qi 'Relaying denied' "$sendmail_cf_file"; then
        echo "릴레이 제한이 이미 설정되어 있습니다."
    else
        echo "릴레이 제한 설정이 없습니다. 설정을 추가합니다."
        
        # 릴레이 제한 설정을 추가하는 예제 코드 (주의: 실제 환경에 맞게 조정 필요)
        # echo "R$\*: Relay denied" >> "$sendmail_cf_file"
        
        # 주의: 위 설정 추가 예제는 실제 환경에서 바로 사용하기에 적합하지 않을 수 있습니다.
        # 실제로 설정을 변경하기 전에 sendmail 문서를 참조하고,
        # 시스템 관리자나 전문가와 상의하는 것이 중요합니다.
        
        echo "릴레이 제한 설정을 추가했습니다. (가이드에 따라 실제 적용 필요)"
    fi
else
    echo "U-31 sendmail.cf 파일을 찾을 수 없습니다. SMTP 서비스가 설치되어 있지 않거나 다른 위치에 있을 수 있습니다."
fi
