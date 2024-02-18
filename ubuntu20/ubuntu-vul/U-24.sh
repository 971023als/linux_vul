#!/bin/bash

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1 

BAR

CODE [U-24] NFS 서비스 비활성화 

cat << EOF >> $result

[양호]: 불필요한 NFS 서비스가 비활성화 되어있는 경우

[취약]: 불필요한 NFS 서비스가 활성화 되어있는 경우

EOF

BAR

# NFS 서비스 데몬(nfsd, statd 및 lockd)이 실행 중인지 확인합니다
NFS=$(ps -ef | egrep "nfsd|statd|lockd" | grep -v grep)

# 결과 변수가 비어 있지 않으면 NFS 서비스 데몬이 실행되고 있습니다
if [ ! -f "$NFS" ]; then
  INFO "NFS 관련 파일이 없습니다"
else
  if [ -n "$NFS" ]; then
    WARN "NFS 서비스 데몬이 실행 중입니다."
  else
    OK "NFS 서비스 데몬이 실행되고 있지 않습니다."
  fi
fi
 
cat $result

echo ; echo