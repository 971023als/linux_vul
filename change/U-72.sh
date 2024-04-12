#!/bin/bash

# 필요한 로깅 정책 설정
ExpectedContent=(
    "*.info;mail.none;authpriv.none;cron.none /var/log/messages"
    "authpriv.* /var/log/secure"
    "mail.* /var/log/maillog"
    "cron.* /var/log/cron"
    "*.alert /dev/console"
    "*.emerg *"
)

ConfigFile="/etc/rsyslog.conf"
BackupFile="/etc/rsyslog.conf.bak"

# rsyslog.conf 파일 백업
if [ ! -f "$BackupFile" ]; then
    sudo cp "$ConfigFile" "$BackupFile"
fi

# 예상되는 로깅 정책이 설정 파일에 있는지 확인하고, 없으면 추가
for line in "${ExpectedContent[@]}"; do
    if ! grep -Fq "$line" "$ConfigFile"; then
        echo "Adding missing policy to $ConfigFile: $line"
        echo "$line" | sudo tee -a "$ConfigFile" > /dev/null
    fi
done

# rsyslog 서비스 재시작
sudo systemctl restart rsyslog

echo "U-72 시스템 로깅 정책 조치가 완료되었습니다."
