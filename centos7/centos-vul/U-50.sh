#!/bin/bash

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1

BAR

CODE [U-50] 관리자 그룹에 최소한의 계정 포함

cat << EOF >> $result

양호: 관리자 그룹에 불필요한 계정이 등록되어 있지 않은 경우

취약: 관리자 그룹에 불필요한 계정이 등록되어 있는 경우

EOF

BAR

# 필요한 계정 목록 정의
necessary_accounts=("root" "bin" "daemon" "adm" "lp" "sync" "shutdown" "halt" "adiosl" "mysql" "cubrid")

# 필요한 계정 목록에 없는 계정 검색
unnecessary_accounts=$(getent group Administrators | awk -F: '{split($4,a,","); for(i in a) {if (!(a[i] in necessary_accounts)) { print a[i] }}}')

# 불필요한 계정이 발견되었는지 확인합니다
if [ -n "$unnecessary_accounts" ]; then
  WARN "Administrators 그룹에서 불필요한 계정이 발견되었습니다.: $unnecessary_accounts"
else
  OK "Administrators 그룹에서 불필요한 계정을 찾을 수 없습니다."
fi

cat $result

echo ; echo
