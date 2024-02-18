#!/bin/bash

 

. function.sh

 

BAR

CODE [U-70] expn, vrfy 명령어 제한

cat << EOF >> $result

[양호]: SMTP 서비스 미사용 또는, noexpn, novrfy 옵션이 설정되어 있는 경우

[취약]: SMTP 서비스 사용하고, noexpn, novrfy 옵션이 설정되어 있지 않는 경우

EOF

BAR

#  백업 파일 생성
cp /etc/rc2.d/S88sendmail_bak /etc/rc2.d/S88sendmail
  

cat $result

echo ; echo 
