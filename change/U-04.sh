#!/bin/bash

echo "U-04 패스워드 파일 보호 설정을 검사합니다..."

# /etc/passwd 파일에서 쉐도우 패스워드 사용 여부 확인
PASSWD_SHADOW_USE=$(grep -v ':x:' /etc/passwd)
if [ -n "$PASSWD_SHADOW_USE" ]; then
    echo "쉐도우 패스워드를 사용하고 있지 않습니다. /etc/passwd 파일을 검토하세요."
    SHADOW_USED=false
else
    echo "/etc/passwd 파일에서 쉐도우 패스워드를 사용하고 있습니다."
    SHADOW_USED=true
fi

# /etc/shadow 파일 존재 및 권한 검사
if [ "$SHADOW_USED" = true ]; then
    if [ -f "/etc/shadow" ]; then
        SHADOW_PERMISSIONS=$(stat -c "%a" /etc/shadow)
        if [ "$SHADOW_PERMISSIONS" -eq "400" ] || [ "$SHADOW_PERMISSIONS" -eq "0" ]; then
            echo "/etc/shadow 파일의 권한 설정이 적절합니다."
        else
            echo "/etc/shadow 파일의 권한 설정이 적절하지 않습니다. 권한을 0400으로 설정하는 것이 좋습니다."
            # /etc/shadow 파일 권한을 0400으로 설정
            chmod 0400 /etc/shadow
            echo "/etc/shadow 파일 권한을 0400으로 조정했습니다."
        fi
    else
        echo "/etc/shadow 파일이 존재하지 않습니다. 시스템 설정을 검토하세요."
    fi
else
    echo "패스워드 보호 설정에 문제가 있습니다. 시스템 설정을 즉시 검토하세요."
fi
