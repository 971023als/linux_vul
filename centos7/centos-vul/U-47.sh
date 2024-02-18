#!/bin/bash

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1  

BAR

CODE [U-47] 패스워드 최대 사용기간 설정

cat << EOF >> $result

[양호]: 패스워드 최대 사용기간이 90일(12주) 이하로 설정되어 있는 경우

[취약]: 패스워드 최대 사용기간이 90일(12주) 이하로 설정되어 있지 않은 경우

EOF

BAR

# login.defs 파일에서 PASS_MAX_DAYS 값을 가져옵니다
pass_max_days=$(grep -E "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')

max=90

# PASS_MAX_DAYS 값이 주석 처리되었는지 확인합니다
if grep -q "^#PASS_MAX_DAYS" /etc/login.defs; then
  INFO "PASS_MAX_DAYS가 주석 처리되었습니다."
else
  # PASS_MAX_DAYS 값이 올바른 정수인지 확인하십시오
  if [ "$pass_max_days" -eq "$pass_max_days" ] 2>/dev/null; then
    # PASS_MAX_DAYS의 값이 지정된 범위 내에 있는지 확인합니다
    if [ "$pass_max_days" -ge 0 ] && [ "$pass_max_days" -le 99999999 ]; then
      if [ "$pass_max_days" -le "$max" ]; then
        OK "PASS_MAX_DAYS가 $max 보다 작거나 같은 $pass_max_days 로 설정되었습니다."
      else
        WARN "PASS_MAX_DAYS가 $max 보다 큰 $pass_max_days 로 설정되었습니다."
      fi
    else
      INFO "PASS_MAX_DAYS 값이 범위를 벗어났습니다."
    fi
  else
    INFO "PASS_MAX_DAYS 값이 올바른 정수가 아닙니다."
  fi
fi

cat $result

echo ; echo
