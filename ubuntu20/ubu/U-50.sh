#!/bin/bash

 

. function.sh

TMP2=$(mktemp)

 

BAR

CODE [U-50] 관리자 그룹에 최소한의 계정 포함

cat << EOF >> $result

양호: 관리자 그룹에 불필요한 계정이 등록되어 있지 않은 경우

취약: 관리자 그룹에 불필요한 계정이 등록되어 있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

necessary_accounts=("root" "bin" "daemon" "adm" 
"lp" "sync" "shutdown" "halt" "ubuntu" "user"
"messagebus" "syslog" "avahi" "kernoops"
"whoopsie" "colord" "systemd-network" 
"systemd-resolve" "systemd-timesync" "mysql"
 "dbus" "rpc" "rpcuser" "haldaemon" 
"apache" "postfix" "gdm" "adiosl" 
"www-data" "user www-data")

all_users=$(getent passwd | awk -F: '{print $1}')

for user in $all_users; do
  if ! echo "${necessary_accounts[@]}" | grep -wq "$user"; then
    userdel "$user"
  fi
done

cat $result

echo ; echo
