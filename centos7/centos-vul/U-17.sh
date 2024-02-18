#!/bin/bash

. function.sh


TMP1=`SCRIPTNAME`.log

>$TMP1   

BAR

CODE [U-17] $HOME/.rhosts, hosts.equiv 사용 금지 

cat << EOF >> $result

[양호]: login, shell, exec 서비스를 사용하지 않거나 사용 시 아래와 같은 설정이 적용된 경우 

1. /etc/hosts.equiv 및 $HOME/.rhosts 파일 소유자가 root 또는, 해당 계정인 경우 

2. /etc/hosts.equiv 및 $HOME/.rhosts 파일 권한이 600 이하인 경우 

3. /etc/hosts.equiv 및 $HOME/.rhosts 파일 설정에 ‘+’ 설정이 없는 경우

[취약]: login, shell, exec 서비스를 사용하고, 위와 같은 설정이 적용되지 않은 경우 

EOF

BAR

equiv_file="/etc/hosts.equiv"
rhosts_file="$HOME/.rhosts"

if [ -f "$equiv_file" ]; then
  equiv_owner=$(stat -c "%U" "$equiv_file")
  if [ "$equiv_owner" = "root" ]; then
    OK "$equiv_file 은 루트에 의해 소유됩니다."
  else
    INFO "$equiv_file 이 루트에 의해 소유되지 않음($equiv_owner 가 소유함)" 
  fi
else
  INFO "$equiv_file 을 찾을 수 없습니다"
fi

if [ -f "$rhosts_file" ]; then
  rhosts_owner=$(stat -c "%U" "$rhosts_file")
  if [ "$rhosts_owner" = "$USER" ]; then
    OK "$rhosts_file 은 $USER 가 소유하고 있습니다."
  else
    INFO "$rhosts_fil e은 $USER($rhosts_owner 소유)가 소유하지 않습니다."
  fi
else
  INFO "$rhosts_file 을 찾을 수 없습니다"
fi


equiv_file="/etc/hosts.equiv"
rhosts_file="$HOME/.rhosts"

if [ -f "$equiv_file" ]; then
  equiv_perms=$(stat -c "%a" "$equiv_file")
  if [ "$equiv_perms" -le "600" ]; then
    OK "$equiv_file 에 허용 가능한 권한($equiv_perms)이 있습니다."
  else
    WARN "$equiv_file 에 허용되지 않는 권한($equiv_perms)이 있습니다."
  fi
else
  INFO "$equiv_file 을 찾을 수 없습니다"
fi

if [ -f "$rhosts_file" ]; then
  rhosts_perms=$(stat -c "%a" "$rhosts_file")
  if [ "$rhosts_perms" -le "600" ]; then
    OK "$rhosts_file 에 허용 가능한 권한($rhosts_perms)이 있습니다."
  else
    WARN "$rhosts_file 에 허용되지 않는 권한($rhosts_perms)이 있습니다."
  fi
else
  INFO "$rhosts_file 을 찾을 수 없습니다"
fi

equiv_file="/etc/hosts.equiv"
rhosts_file="$HOME/.rhosts"

check_file() {
  file=$1
  if [ -f "$file" ]; then
    if grep -q "+" "$file"; then
      WARN "$file '+' 설정이 있습니다"
    else
      OK "$file  '+' 설정이 없습니다"
    fi
  else
    INFO "$file 을 찾을 수 없습니다"
  fi
}

check_file "$equiv_file"
check_file "$rhosts_file"



cat $result

echo ; echo
 
