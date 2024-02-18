#!/bin/bash

 

. function.sh


 

BAR

CODE [U-49] 불필요한 계정 제거

cat << EOF >> $result

[양호]: 불필요한 계정이 존재하지 않는 경우

[취약]: 불필요한 계정이 존재하는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

# 기본 계정 목록 지정
default_accounts=(
  "root"
  "bin"
  "daemon"
  "adm"
  "lp"
  "sync"
  "shutdown"
  "halt"
  "ubuntu"
  "user"
  "messagebus"
  "syslog"
  "avahi"
  "kernoops"
  "whoopsie"
  "colord"
  "systemd-network"
  "systemd-resolve"
  "systemd-timesync"
  "mysql"
  "dbus"
  "rpc"
  "rpcuser"
  "haldaemon"
  "apache"
  "postfix"
  "gdm"
  "sys"
  "games"
  "man"
  "news"
  "uucp"
  "proxy"
  "www-data"
  "backup"
  "list"
  "irc"
  "gnarts"
  "nobody"
  "_apt"
  "tss"
  "uuidd"
  "tcpdump"
  "avahi-autoipad"
  "usbmux"
  "rtkit"
  "dnsmasq"
  "cups-pk-helper"
  "speech-dispatcher"
  "saned"
  "nm-openvpn"
  "hplip"
  "geoclue"
  "pulse"
  "gnone-initial-setup"
  "systmd-coredump"
  "fwupd-refresh"
  "adiosl"
  "cubrid"
)

# 셸이 bash로 설정된 사용자 목록을 /etc/passwd에서 가져옵니다
user_list=$(cat /etc/passwd | grep bash | awk -F: '{print $1}')

# 사용자 목록을 순환
for user in $user_list; do
  # 사용자가 기본 계정인지 확인합니다
  if echo "$default_accounts" | grep -qw "$user"; then
    # 아무것도 하지마
    OK "bash 셸을 사용하는 일반 사용자 계정이 없습니다."
  else
    INFO "기본이 아닌 계정 제거 중: $user"
    userdel "$user"
  fi
done

 
cat $result

echo ; echo
