#!/bin/bash

. function.sh

BAR

CODE [U-27]  RPC 서비스 확인 

cat << EOF >> $result

[양호]: 불필요한 RPC 서비스가 비활성화 되어 있는 경우

[취약]: 불필요한 RPC 서비스가 활성화 되어 있는 경우


EOF

BAR

services=("rpc.cmsd" "rpc.ttdbserverd" "sadmin" "rusersd" "walld" "sprayd" "rstatd" "rpc.nisd" "rexd" "rpc.pcnfsd" "rpc.statd" "rpc.ypupdated" "rpc.requotad" "kcms_server" "cachefsd")

for service in "${services[@]}"; do
  if service $service status; then
    WARN "$service 서비스가 활성"
  else
    OK "$service 서비스가 활성화되지 않았습니다."
  fi
done

cat $result

echo ; echo