#!/bin/bash

 

. function.sh

 

TMP1=`SCRIPTNAME`.log

> $TMP1

TMP2=/tmp/tmp1

> $TMP2

 

BAR

CODE [U-53] 사용자 shell 점검

cat << EOF >> $result

[취약]: 로그인이 필요하지 않은 계정에 /bin/false(nologin) 쉘이 부여되어 있는 경우

[양호]: 로그인이 필요하지 않은 계정에 /bin/false(nologin) 쉘이 부여되지 않은 경우

EOF

BAR

# 명령 출력에서 사용자 목록 가져오기
user_list=$(cat /etc/passwd | egrep "^daemon|^bin|^sys|^adm|^listen|^nobody|^nobody4|^ noaccess|^diag|^operator|^games|^gopher" | grep -v "admin" | awk -F: '{print $1}')

# 사용자 목록을 순환
for user in $user_list; do
  # 사용자의 셸 가져오기
  shell=$(grep "^$user:" /etc/passwd | awk -F: '{print $7}')

# 셸이 /bin/false인지 /sbin/nologin인지 확인합니다
  if [[ $shell == "/bin/false" || $shell == "/sbin/nologin" ]]; then
    OK "사용자 $user 셸이 $shell 로 설정됨"
  else
    WARN "사용자 $use r의 셸이 /bin/false 또는 /sbin/nlogin으로 설정되어 있지 않습니다. 현재 셸은 $shell 입니다."
  fi
done
 

cat $result

echo ; echo
