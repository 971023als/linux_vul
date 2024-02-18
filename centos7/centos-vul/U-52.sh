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

PASSWD="/etc/passwd"

uid_list=$(awk -F: '{print $3}' "$PASSWD")
duplicate_uids=$(echo "$uid_list" | sort | uniq -d)

if [ ! -f "$PASSWD" ]; then
	INFO "$PASSWD 파일이 없습니다."
else
	if [ -n "$duplicate_uids" ]; then
		WARN "UID가 동일한 사용자 계정이 있습니다: $duplicate_uids"
	else
		OK "같은 UID를 가진 사용자 계정이 없습니다."
	fi
fi
																																																					

cat $result

echo ; echo
