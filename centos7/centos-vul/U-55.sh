#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1
 

BAR

CODE [U-55] hosts.lpd 파일 소유자 및 권한 설정

cat << EOF >> $result

[양호]: 파일의 소유자가 root이고 권한이 600인 경우

[취약]: 파일의 소유자가 root가 아니고 권한이 600이 아닌 경우

EOF

BAR

# 파일이 있는지 확인하십시오
if [ ! -f /etc/hosts.lpd ]; then
  INFO "hosts.lpd 파일이 없습니다. 확인해주세요."
else
  hosts=$(stat -c '%U' /etc/hosts.lpd)
  if [[ $hosts = "root" ]]; then
    OK "hosts.lpd의 소유자는 루트입니다. 이것은 허용됩니다."
  else
    WARN "hosts.lpd의 소유자는 루트가 아닙니다. 이것은 허용되지 않습니다."
  fi
  
  # 파일에 대한 사용 권한 확인

  host=$(stat -c %a /etc/hosts.lpd)
  if [[ $host -gt 600 ]]; then
    WARN "hosts.lpd에 대한 권한이 600보다 큽니다."
  else
    OK "hosts.lpd에 대한 권한이 600이하 입니다."
  fi
fi


cat $result

echo ; echo
