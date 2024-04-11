#!/bin/bash

# Telnet 서비스 비활성화
echo "Telnet 서비스 비활성화 확인 중..."
if grep -E "telnet\s+\d+/tcp" /etc/services; then
    echo "Telnet 서비스가 활성화되어 있습니다. 이를 비활성화하려면 시스템 관리자에게 문의하세요."
else
    echo "Telnet 서비스가 비활성화되어 있습니다."
fi

# SSH에서 root 로그인 제한
echo "SSH 서비스에서 root 계정의 원격 접속 제한 설정 중..."
FOUND=0
for sshd_config in $(find /etc/ssh -name 'sshd_config'); do
    if grep -E "^[^#]*PermitRootLogin" $sshd_config; then
        echo "PermitRootLogin 설정이 발견되었습니다. 제한을 강화합니다."
        sed -i '/^PermitRootLogin/c\PermitRootLogin no' $sshd_config
        FOUND=1
        echo "$sshd_config 파일이 업데이트되었습니다."
        break
    fi
done

if [ $FOUND -ne 1 ]; then
    echo "SSH 설정 파일에서 PermitRootLogin 설정을 찾을 수 없습니다. 설정 파일을 수동으로 확인하십시오."
fi

# SSH 서비스 재시작 (Ubuntu/Debian 기준, 다른 배포판은 서비스 명령어가 다를 수 있음)
echo "SSH 서비스를 재시작합니다..."
systemctl restart ssh

echo "U-01 보안 조치가 완료되었습니다."
