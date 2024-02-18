#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1

 

BAR

CODE [U-48] 패스워드 최소 사용기간 설정

cat << EOF >> $result

[양호]: 패스워드 최소 사용기간이 1일(1주)로 설정되어 있는 경우

[취약]: 패스워드 최소 사용기간이 설정되어 있지 않는 경우

EOF

BAR

# /etc/login.defs에서 PASS_MIN_DAYS 값을 읽습니다
pass_min_days=$(grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')

min_days=7

# PASS_MIN_DAYS 값이 주석 처리되었는지 확인합니다
if grep -q "^#PASS_MIN_DAYS" /etc/login.defs; then
  INFO "PASS_MIN_DAYS가 주석 처리되었습니다."
else
  # PASS_MIN_DAYS 값이 올바른 정수인지 확인하십시오
  if [ "$pass_min_days" -eq "$pass_min_days" ] 2>/dev/null; then
    # PASS_MIN_DAYS의 값이 지정된 범위 내에 있는지 확인합니다
    if [ "$pass_min_days" -ge 0 ] && [ "$pass_min_days" -le 99999999 ]; then
      if [ "$pass_min_days" -ge "$min_days" ]; then
        OK "PASS_MIN_DAYS이 $pass_min_days 으로 설정되어 $min_days 보다 크거나 같습니다."
      else
        WARN "PASS_MIN_DAYS이 $min_days 보다 작은 $pass_min_days 으로 설정되었습니다."
      fi
    else
      INFO " PASS_MIN_DAYS 값이 범위를 벗어났습니다."
    fi
  else
    INFO " PASS_MIN_DAYS 값이 올바른 정수가 아닙니다."
  fi
fi

cat $result

echo ; echo
