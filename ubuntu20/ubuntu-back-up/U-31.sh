#!/bin/bash

. function.sh

BAR

CODE [U-31] 스팸 메일 릴레이 제한		

cat << EOF >> $result

[양호]: SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정되어 있는 경우

[취약]: SMTP 서비스를 사용하며 릴레이 제한이 설정되어 있지 않은 경우

EOF

BAR
#    백업 파일 생성
cp /etc/mail/sendmail.cf.bak /etc/mail/sendmail.cf 


cat $result

echo ; echo
