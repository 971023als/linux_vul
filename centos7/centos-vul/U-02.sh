#!/bin/bash 

. function.sh

TMP1=$(SCRIPTNAME).log

> $TMP1

 
BAR

CODE [U-02] 패스워드 복잡성 설정

cat << EOF >> $result

[양호]: 영문 숫자 특수문자가 혼합된 8 글자 이상의 패스워드가 설정된 경우.

[취약]: 영문 숫자 특수문자 혼합되지 않은 8 글자 미만의 패스워드가 설정된 경우.

EOF

BAR

# login.defs 파일에서 PASS_MAX_DAYS 값을 가져옵니다
LOGIN_DEFS_FILE="/etc/login.defs"
PASS_MIN_LEN_OPTION="PASS_MIN_LEN"
min=8

# PASS_MIN_LEN 가장 높은 값
highest_value=0
while read line; do
  if [[ $line =~ ^$PASS_MIN_LEN_OPTION[[:space:]]+([0-9]+) ]]; then
    value=${BASH_REMATCH[1]}
    if [ $value -gt $highest_value ]; then
      highest_value=$value
    fi
  fi
done < "$LOGIN_DEFS_FILE"

# PASS_MIN_LEN의 값이 지정된 범위 내에 있는지 확인합니다
if [ "$highest_value" -ge "$min" ]; then
   OK "8 글자 이상의 패스워드가 설정된 경우"
else
   WARN "8 글자 미만의 패스워드가 설정된 경우"
fi



PAM_FILE="/etc/pam.d/system-auth"
EXPECTED_OPTIONS="password requisite pam_cracklib.so try_first_pass restry=3 minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1"


if [ -f "$PAM_FILE" ]; then
    if grep -q "$EXPECTED_OPTIONS" "$PAM_FILE" ; then
        OK " $PAM_FILE 에 $EXPECTED_OPTIONS 있음  "
    else
        WARN " $PAM_FILE 에 $EXPECTED_OPTIONS 없음  "
    fi
else
    INFO " $PAM_FILE 못 찾음"
fi


cat $result

echo ; echo
