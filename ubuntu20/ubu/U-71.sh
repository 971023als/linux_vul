#!/bin/bash

. function.sh
 
BAR

CODE [U-71] Apache 웹서비스 정보 숨김

cat << EOF >> $result

[양호]: ServerTokens Prod, ServerSignature Off로 설정되어있는 경우

[취약]: ServerTokens Prod, ServerSignature Off로 설정되어있지 않은 경우

EOF

BAR


TMP1=`SCRIPTNAME`.log

> $TMP1 

filename="/etc/apache2/apache2.conf"

# 파일이 있는지 확인하십시오
if [ ! -e "$filename" ]; then
  INFO "$filename 없음"
else 
  OK "$filename 있음"
fi

#  apache2.conf 파일에서 "ServerTokens Full"을 "ServerTokens Prod"로 바꿉니다
sed -i 's/ServerTokens Full/ServerTokens Prod/g' "$filename"

# apache2.conf 파일에서 "ServerSignatureOn"을 "ServerSignatureOff"로 바꿉니다
sed -i 's/ServerSignature On/ServerSignature Off/g' "$filename"

# ServerTokens가 설정되어 있는지 확인합니다
if ! grep -q "ServerTokens Prod" "$filename"; then
  echo "ServerTokens Prod" >> "$filename"
fi

# ServerSignature가 설정되어 있는지 확인합니다
if ! grep -q "ServerSignature Off" "$filename"; then
  echo "ServerSignature Off" >> "$filename"
fi

cat $result

echo ; echo 