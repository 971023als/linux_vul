#!/bin/bash

. function.sh

BAR

CODE [U-52] 동일한 UID 금지

cat << EOF >> $result

양호: 동일한 UID로 설정된 사용자 계정이 존재하지 않는 경우

취약: 동일한 UID로 설정된 사용자 계정이 존재하는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

> $TMP1

# 사용자 계정이 포함된 파일
PASSWD="/etc/passwd"

# awk 명령 결과를 저장할 임시 파일
TMP2=$(mktemp)

# awk 명령의 결과를 임시 파일에 저장합니다
awk -F: '{print $1 ":" $3}' "$PASSWD" > $TMP2

# 중복된 UID 목록을 배열에 저장
DUPLICATE_UIDS=($(cut -d: -f2 $TMP2 | sort | uniq -d))

# 중복된 각 사용자 계정의 UID 변경
for uid in "${DUPLICATE_UID[@]}"; do
  # 중복된 UID를 가진 사용자 목록 가져오기
  USERS=($(grep ":$uid" $TMP2 | cut -d: -f1))

  # 사용자를 루프하여 UID를 고유한 값으로 변경
  for user in "${USERS[@]}"; do
    # 사용자의 현재 UID 가져오기
    CURR_UID=$(id -u $user)

    # 현재 UID가 중복되는지 확인하십시오
    if [ $CURR_UID -eq $uid ]; then
      # 고유한 UID 생성
      NEW_UID=$(($CURR_UID + 1))

      # 사용자의 UID 변경
      usermod -u $NEW_UID $user

      # 결과 인쇄
      INFO "$user 의 UID가 $CURR_UID 에서 $NEW_UID 로 변경됨"
    fi
  done
done

# 임시 파일 제거
rm $TMP2



cat $result

echo ; echo
