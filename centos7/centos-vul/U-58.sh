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

# Get a list of all accounts
accounts=`cat /etc/passwd | cut -d: -f1`

# Loop through all accounts
for account in $accounts; do

  # Get the home directory of the account
  home=`cat /etc/passwd | grep $account | cut -d: -f6`

  # Check if the home directory is empty
  if [ -z "$home" ]; then
    WARN "Account $account 홈 디렉토리가 없습니다."
  fi
done

OK "모든 계정에는 홈 디렉토리가 있습니다"



cat $result

echo ; echo

