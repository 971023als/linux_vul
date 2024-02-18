#!/bin/bash

 

. function.sh

 

BAR

CODE [U-70] expn, vrfy 명령어 제한

cat << EOF >> $result

[양호]: SMTP 서비스 미사용 또는, noexpn, novrfy 옵션이 설정되어 있는 경우

[취약]: SMTP 서비스 사용하고, noexpn, novrfy 옵션이 설정되어 있지 않는 경우

EOF

BAR

# 송신 메일 프로세스의 PID 가져오기
pid=$(ps -ef | grep sendmail | awk '{print $2}')

# PID를 사용하여 송신 메일 프로세스 중지
kill -9 $pid

# /etc/rc2.d에서 sendmail init 스크립트 이동
mv /etc/rc2.d/S88sendmail /etc/rc2.d/S88sendmail_bak    

cat $result

echo ; echo 
