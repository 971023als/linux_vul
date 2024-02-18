#!/bin/bash

. function.sh

BAR

CODE [U-26] automountd 제거		

cat << EOF >> $result

[양호]: automountd 서비스가 비활성화 되어 있는 경우

[취약]: automountd 서비스가 활성화 되어 있는 경우

EOF

BAR

# 자동 마운트 서비스의 상태를 확인하십시오
status=$(ps -ef | grep automount | awk '{print $1}')

# 서비스가 실행 중인 경우 프로세스 ID를 삭제하여 서비스를 중지합니다
if [ "$status" == "online" ]; then
  pid=$(ps -ef | grep automount | awk '{print $3}' | awk -F ',' '{print $1}')
  kill -9 $pid
fi

# 시작 스크립트의 이름을 변경하여 자동 마운트 서비스 사용 안 함
if [ -f "/etc/rc.d/rc2.d/S28automountd" ]; then
  mv /etc/rc.d/rc2.d/S28automountd /etc/rc.d/rc2.d/_S28automountd
fi

cat $result

echo ; echo
