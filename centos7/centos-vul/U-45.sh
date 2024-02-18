#!/bin/bash

. function.sh


TMP1=`SCRIPTNAME`.log

> $TMP1

BAR

CODE [U-45] root 계정 su 제한

cat << EOF >> $result

[양호]: su 명령어를 특정 그룹에 속한 사용자만 사용하도록 제한되어 있는 경우

[취약]: su 명령어를 모든 사용자가 사용하도록 설정되어 있는 경우

EOF

BAR

# 휠 그룹이 존재하는지 점검하십시오
if ! grep -q "^wheel:" /etc/group; then
  WARN "휠 그룹이 존재하지 않습니다."
else
  OK "휠 그룹이 존재합니다."
fi

# su 명령이 휠 그룹에 의해 소유되는지 점검하십시오
if ! [ $(stat -c %G /bin/su) == "wheel" ]; then
  WARN "su 명령은 휠 그룹이 소유하지 않습니다."
else
  OK "su 명령은 휠 그룹이 소유합니다."
fi

# su 명령에 권한 4750이 있는지 확인하십시오
if ! [ $(stat -c %a /bin/su) == "4750" ]; then
  WARN "su 명령에 올바른 권한이 없습니다."
else
  OK "su 명령에 올바른 권한이 있습니다."
fi

# 휠 그룹에 su 명령을 사용할 수 있는 계정이 있는지 확인하십시오
found=false
for user in $(grep "^wheel:" /etc/group | cut -d ":" -f4 | tr "," "\n"); do
  if id -nG "$user" | grep -qw "wheel"; then
    found=true
    break
  fi
done

if ! $found; then
  WARN "휠 그룹의 어떤 계정도 su 명령을 사용할 수 없습니다."
else
  OK "휠 그룹의 어떤 계정도 su 명령을 사용할 수 있습니다."
fi

 

cat $result

echo ; echo
