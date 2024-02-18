#!/bin/bash

. function.sh 
   
BAR

CODE [U-42] 최신 보안패치 및 벤더 권고사항 적용

cat << EOF >> $result

[양호]: 패치 적용 정책을 수립하여 주기적으로 패치를 관리하고 있는 경우

[취약]: 패치 적용 정책을 수립하지 않고 주기적으로 패치관리를 하지 않는 경우

EOF

BAR

# 로그 파일 경로 설정
log_file="/var/log/patch.log"

# /var/log/patch.log 파일이 이미 있는지 확인하십시오
if [ -e $log_file ]; then
  OK " $log_file 가 이미 있습니다."
else
  WARN " $log_file 생성 시작합니디."
fi

# /var/log/patch.log 파일 생성
touch $log_file

# 파일에 대한 적절한 사용 권한 및 소유권 설정
chmod 644 $log_file
chown root:root $log_file

# 변수에 날짜 저장
date=$(date +%Y-%m-%d)

# 시스템 업데이트 및 업그레이드
apt update -y
apt upgrade -y

# 파일에 패치 명령 기록
echo "Patches installed on $date" | tee -a $log_file

cat $result

echo ; echo 

 
