#!/bin/bash

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1
 

BAR

CODE [U-21] r 계열 서비스 비활성화

cat << EOF >> $result

[양호]: r 계열 서비스가 비활성화 되어 있는 경우

[취약]: r 계열 서비스가 활성화 되어 있는 경우

EOF

BAR

files=(/etc/xinetd.d/rlogin /etc/xinetd.d/rsh /etc/xinetd.d/rexec)
expected_settings=(
"socket_type= stream"
"wait= no"
"user= nobody"
"log_on_success+= USERID"
"log_on_failure+= USERID"
"server= /usr/sdin/in.fingerd"
"disable= yes"
)

for file in "${files[@]}"; do
  INFO "파일 확인 중: $file"
  if [ ! -f "$file" ]; then
	  INFO "$file 파일이 없습니다."
  else
    for setting in "${expected_settings[@]}"; do
      if grep -q "$setting" "$file"; then
        OK "'$setting'이 올바르게 설정되었습니다."
      else
        WARN "$file 파일에서 '$setting'을 올바르게 설정하지 않았습니다."
      fi
    done
  fi
done

cat $result

echo ; echo