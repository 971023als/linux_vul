#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-71] Apache 웹서비스 정보 숨김

cat << EOF >> $result

[양호]: ServerTokens Prod, ServerSignature Off로 설정되어있는 경우

[취약]: ServerTokens Prod, ServerSignature Off로 설정되어있지 않은 경우

EOF

BAR

filename="/etc/httpd/conf/httpd.conf"

if [ ! -e "$filename" ]; then
  WARN "$filename 가 존재하지 않습니다"
fi

server_tokens=$(grep -i 'ServerTokens Prod' "$filename")
server_signature=$(grep -i 'ServerSignature Off' "$filename")

if [ "$server_tokens" == "ServerTokens Prod" ]; then
  OK "서버 토큰 설정이 Prod로 설정되었습니다."
else
  WARN "서버 토큰 설정이 Prod로 설정되지 않았습니다."
fi

if [ "$server_signature" == "ServerSignature Off" ]; then
  OK "Server Signature 설정이 Off로 설정되었습니다."
else
  WARN "Server Signature 설정이 Off로 설정되지 않았습니다."
fi


cat $result

echo ; echo 