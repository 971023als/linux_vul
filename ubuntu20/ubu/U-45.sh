#!/bin/bash

. function.sh

BAR

CODE [U-45] root 계정 su 제한		

cat << EOF >> $result

[양호]: su 명령어를 특정 그룹에 속한 사용자만 사용하도록 제한되어 있는 경우
※ 일반사용자 계정 없이 root 계정만 사용하는 경우 su 명령어 사용제한 불필요

[취약]: su 명령어를 모든 사용자가 사용하도록 설정되어 있는 경우

EOF

BAR

# su 명령을 사용해야 하는 계정 목록
accounts=("root" "bin" "daemon"  "lp" "sync" "user"
"messagebus" "syslog" "avahi" "kernoops"
"whoopsie" "colord" "systemd-network" 
"systemd-resolve" "systemd-timesync" "mysql" 
"gdm" "www-data" "user www-data")

# 원래의 wheel 그룹 삭제
groupdel wheel

# 새로운 wheel 그룹 추가
groupadd -r wheel

# 명령어 그룹을 변경
chgrp wheel /bin/su

chmod 4750 /bin/su

# su 명령의 허가를 4750으로 변경하다
for account in "${accounts[@]}"; do
  usermod -aG wheel $account
done

# 변경 사항을 확인하다
for account in "${accounts[@]}"; do
  groups $account | grep wheel
done

cat $result

echo ; echo

