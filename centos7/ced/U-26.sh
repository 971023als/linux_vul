#!/bin/bash

. function.sh

BAR

CODE [U-26] automountd 제거		

cat << EOF >> $result

[양호]: automountd 서비스가 비활성화 되어 있는 경우

[취약]: automountd 서비스가 활성화 되어 있는 경우

EOF

BAR



INFO "이 부분은 백업 파일 관련한 항목이 아닙니다"

#---------------------------------------------------

#sudo service automountd start

#sudo service automountd status

#  자동 마운트 서비스의 상태를 확인
status=$(ps -ef | grep automount | awk '{print $1}')

# 서비스가 실행되고 있지 않으면 서비스를 시작
if [ "$status" != "online" ]; then
/usr/sbin/automountd &
fi

# 시작 스크립트의 이름을 변경하여 자동 마운트 서비스 사용
if [ -f "/etc/rc.d/rc2.d/_S28automountd" ]; then
mv /etc/rc.d/rc2.d/_S28automountd /etc/rc.d/rc2.d/S28automountd
fi


cat $result

echo ; echo
