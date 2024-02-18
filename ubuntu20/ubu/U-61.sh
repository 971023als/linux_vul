#!/bin/bash

. function.sh

BAR

CODE [U-61] ftp 서비스 확인

cat << EOF >> $result

[양호]: FTP 서비스가 비활성화 되어 있는 경우

[취약]: FTP 서비스가 활성화 되어 있는 경우

EOF

BAR

apt install net-tools -y

apt-get install -y iproute2

# FTP 서비스 중지
service ftp stop

# FTP 서비스 사용 안 함
service ftp disable

# vsftpd 서비스를 중지합니다:
service vsftpd stop

# vsftpd 서비스를 시작하지 않도록 설정합니다
/etc/rc.d/init.d/vsftpd stop

# proftp 서비스를 중지합니다:
service proftp stop

# proftp를 시작하지 않도록 설정합니다
/etc/rc.d/init.d/proftp stop

# FTP 포트가 수신 중인지 확인합니다
if ss -tnlp | grep -q ':21'; then
  INFO "FTP 포트 닫기(21)..."
  iptables -A INPUT -p tcp --dport 21 -j DROP
else
  OK "FTP 포트(21)가 열려 있지 않습니다."
fi

# /etc/passwd에서 FTP 계정을 확인합니다
ftp_entry=$(grep "^ftp:" /etc/passwd)

# FTP 계정의 셸을 /bin/false로 변경합니다
sudo chsh -s /bin/false ftp

cat $result

echo ; echo 
