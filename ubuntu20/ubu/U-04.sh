#!/bin/bash

. function.sh
 
 TMP1=`SCRIPTNAME`.log

> $TMP1

BAR

CODE [U-04] 패스워드 파일 보호

cat << EOF >> $result

[양호]: 쉐도우 패스워드를 사용하거나, 패스워드를 암호화하여 저장하는 경우

[취약]: 쉐도우 패스워드를 사용하지 않고, 패스워드를 암호화하여 저장하지 않는 경우

EOF

BAR

SHADOW_FILE="/etc/shadow"
PASSWD_FILE="/etc/passwd"

# 섀도 파일이 있는지 확인하십시오
if [ -f $SHADOW_FILE ] ; then
  OK "섀도우 파일이 있습니다."

  # 섀도 파일에 암호화되지 않은 암호가 있는지 확인
  CHECK=$(cat $PASSWD_FILE | awk -F: '{print $2}' | grep -v 'x')
  if [ -z $CHECK ] ; then
    OK "시스템이 암호화된 암호를 사용합니다."
  else
    INFO "섀도우 파일에서 암호화되지 않은 암호를 암호화하는 중..."
    # 암호화되지 않은 암호 목록 반복
    for PASSWORD in $CHECK; do
      # mkpasswd 유틸리티를 사용하여 암호화
      ENCRYPTED_PASSWORD=$(mkpasswd -m sha-512 $PASSWORD)
      # 암호화되지 않은 암호를 섀도 파일의 암호화된 암호로 바꿉니다
      sed -i "s/$PASSWORD/$ENCRYPTED_PASSWORD/g" $SHADOW_FILE
    done
    OK "섀도우 파일에서 암호화되지 않은 암호의 암호화가 완료되었습니다."
  fi
else
  WARN "섀도우 파일이 없습니다."
fi

cat $result

echo ; echo
