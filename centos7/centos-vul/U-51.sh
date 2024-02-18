#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log


BAR

CODE [U-51] 계정이 존재하지 않는 GID 금지

cat << EOF >> $result

양호: 존재하지 않는 계정에 GID 설정을 금지한 경우

취약: 존재하지 않은 계정에 GID 설정이 되어있는 경우

EOF

BAR


declare -a necessary_groups=("root" "sudo" "sys" "adm" "wheel" 
"daemon" "bin" "lp" "dbus" "rpc" "rpcuser" "haldaemon" 
"apache" "postfix" "gdm" "adiosl" "mysql" "cubrid"
 "messagebus" "syslog" "avahi" "whoopsie"
"colord" "systemd-network" "systemd-resolve"
"systemd-timesync" "mysql" "sync" "user"
"tty" "disk" "men" "kmen" "mail" "uucp"
"man" "games" "gopher" "video" "dip"
"ftp" "lock" "audio" "nobody" "users"
"usbmuxd" "utmp" "utempter" "rtkit"
"avahi-autoipd" "desktop_admin_r"
"desktop_user_r" "floppy"
"vcsa" "abrt" "cdrom" "tape"
"dialout" "wbpriv" "nfsnonody"
"ntp" "saslauth" "postdrop"
"pulse" "pulse-access" "fuse" 
"sshd" "slocate" "stapusr"
"stapsys" "tcpdump" "named"
"www-data" "sasl" "nogroup"
"ssh" "nfsnobody" "stapdev"
"mem" "kmem")


all_groups=$(getent group | cut -d: -f1)

for group in $all_groups; do
  if ! [[ " ${necessary_groups[@]} " =~ " ${group} " ]]; then
    WARN "Group ${group}은(는) 시스템 관리 또는 운영에 필요하지 않으므로 검토해야 합니다."
  else
    OK "Group ${group}은(는) 시스템 관리 또는 운영에 필요합니다."
  fi
done



 

cat $result

echo ; echo
