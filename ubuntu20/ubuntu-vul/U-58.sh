#!/bin/bash

. function.sh
 
TMP1=`SCRIPTNAME`.log

> $TMP1  
 

BAR

CODE [U-58] 홈 디렉터리로 지정한 디렉터리의 존재 관리 

cat << EOF >> $result

[양호]: 홈 디렉터리가 존재하지 않는 계정이 발견되지 않는 경우

[취약]: 홈 디렉터리가 존재하지 않는 계정이 발견된 경우

EOF

BAR


# 모든 계정 목록 가져오기
accounts=`cat /etc/passwd | cut -d: -f1`

# 모든 계정에 반복 실행
for account in $accounts; do

  # 계정의 홈 디렉토리를 가져옵니다
  home=`cat /etc/passwd | grep $account | cut -d: -f6`

  # 홈 디렉토리가 비어 있는지 확인합니다
  if [ -z "$home" ]; then
    WARN "Account $account 홈 디렉토리가 없습니다."
  fi
done

OK "모든 계정에는 홈 디렉토리가 있습니다"


cat $result

echo ; echo

