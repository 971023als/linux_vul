#!/bin/bash

. function.sh

BAR

CODE [U-44] root 이외의 UID가 '0' 금지

cat << EOF >> $result

[양호]: root 계정과 동일한 UID를 갖는 계정이 존재하지 않는 경우

[취약]: root 계정과 동일한 UID를 갖는 계정이 존재하는 경우

EOF

BAR

FILE=/etc/passwd

# 루트 계정과 동일한 UID를 가진 계정 확인(UID 값 0)
awk -F: '$3=="0"{print $1":"$3}' $FILE > $TMP1
UIDCHECK=$(wc -l < $TMP1)
if [ $UIDCHECK -ge 2 ]; then
   WARN "루트 계정과 동일한 UID를 가진 계정이 있습니다."
   INFO "자세한 내용은 $TMP1 을 확인하십시오."
else
   OK "루트 계정과 동일한 UID를 가진 계정이 없습니다."
   rm $TMP1
fi

cat $result

echo ; echo
