#!/bin/bash

. function.sh

BAR

CODE [U-24] NFS 서비스 비활성화		

cat << EOF >> $result

[양호]: 불필요한 NFS 서비스 관련 데몬이 비활성화 되어 있는 경우

[취약]: 불필요한 NFS 서비스 관련 데몬이 활성화 되어 있는 경우

EOF

BAR

# 명명된 프로세스가 실행 중인지 확인하십시오
PIDs=$(ps -ef | egrep "nfs|statd|lockd" | awk '{print $2}')

# 프로세스 ID를 사용하여 명명된 프로세스 중지
for PID in $PIDs; do
    kill -9 $PID
done

# 부팅 시 프로세스 시작 사용 안 함
if [ -f "/etc/init.d/nfs" ]; then
  update-rc.d nfs disable
fi
if [ -f "/etc/init.d/statd" ]; then
  update-rc.d statd disable
fi
if [ -f "/etc/init.d/lockd" ]; then
  update-rc.d lockd disable
fi

mv /etc/rc.d/rc2.d/S60nfs /etc/rc.d/rc2.d/_S60nfs

cat $result

echo ; echo
