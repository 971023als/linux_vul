#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1 

BAR

CODE [U-46] 패스워드 최소 길이 설정

cat << EOF >> $result

[양호]: 패스워드 최소 길이가 8자 이상으로 설정되어 있는 경우

[취약]: 패스워드 최소 길이가 8자 미만으로 설정되어 있는 경우

EOF

BAR


TMP1=`SCRIPTNAME`.log

> $TMP1

# login.defs 파일에서 PASS_MIN_LEN 값을 가져옵니다
pass_min_len=$(grep -E "^PASS_MIN_LEN" /etc/login.defs | awk '{print $2}')

pass=8

# PASS_MIN_LEN 값이 주석 처리되었는지 확인합니다
if grep -q "^#PASS_MIN_LEN" /etc/login.defs; then
  INFO "PASS_MIN_LEN가 주석 처리되었습니다."
else
  # PASS_MIN_LENS 값이 올바른 정수인지 확인하십시오
  if [ "$pass_min_len" -eq "$pass_min_len" ] 2>/dev/null; then
    # PASS_MIN_LEN의 값이 지정된 범위 내에 있는지 확인합니다
    if [ "$pass_min_len" -ge 0 ] && [ "$pass_min_len" -le 99999999 ]; then
      if [ "$pass_min_len" -ge "$pass" ]; then
        OK "PASS_MIN_LEN이 $pass_min_len 으로 설정되어 $pass 보다 크거나 같습니다."
      else
        WARN "PASS_MIN_LEN이 $pass 보다 작은 $pass_min_len 으로 설정되었습니다."
      fi
    else
      INFO " PASS_MIN_LEN 값이 범위를 벗어났습니다."
    fi
  else
    INFO " PASS_MIN_LEN 값이 올바른 정수가 아닙니다."
  fi
fi

cat $result

echo ; echo
