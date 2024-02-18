#!/bin/bash

. function.sh

BAR

CODE [U-44] root 이외의 UID가 ‘0’ 금지

cat << EOF >> $result

[양호]: root 계정과 동일한 UID를 갖는 계정이 존재하지 않는 경우

[취약]: root 계정과 동일한 UID를 갖는 계정이 존재하는 경우

EOF

BAR

# 루트 계정과 동일한 UID를 가진 계정의 사용자 이름을 가져옵니다
username=$(awk -F: '$3==0{print $1}' /etc/passwd)

if [ -n "$username" ]; then
  # UID 배열
  uids=(2023 2024 2025)

  for uid in "${uids[@]}"; do
    # 계정의 UID 변경
   usermod -u $uid $username
  done
else
  OK "루트 계정과 동일한 UID를 가진 계정을 찾을 수 없습니다"
fi

cat $result

echo ; echo