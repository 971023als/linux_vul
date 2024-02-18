#!/bin/bash

. function.sh

BAR

CODE [U-43] 로그의 정기적 검토 및 보고

cat << EOF >> $result

[양호]: 접속기록 등의 보안 로그, 응용 프로그램 및 시스템 로그 기록에 대해 정기적으로 검토, 분석, 리포트 작성 및 보고 등의 조치가 이루어지는 경우

[취약]: 위 로그 기록에 대해 정기적으로 검토, 분석, 리포트 작성 및 보고 등의 조치가 이루어 지지 않는 경우

EOF

BAR

# /var/log/utmp 파일이 이미 있는지 확인하십시오
if [ -e "/var/log/utmp" ]; then
  OK "/var/log/utmp가 이미 있습니다."
else
  WARN "/var/log/utmp가 없습니다."
fi


# /var/log/utmp 파일 생성
touch /var/log/utmp

# 파일에 대한 적절한 사용 권한 및 소유권 설정
chmod 644 /var/log/utmp
chown root:utmp /var/log/utmp


# 로그 파일을 확인하기 위해 함수를 호출합니다
check_log_files


ALLOWED_USERS=(
  "root"
  "bin"
  "daemon"
  "adm"
  "lp"
  "sync"
  "shutdown"
  "halt"
  "ubuntu"
  "user"
  "messagebus"
  "syslog"
  "avahi"
  "kernoops"
  "whoopsie"
  "colord"
  "systemd-network"
  "systemd-resolve"
  "systemd-timesync"
  "mysql"
  "dbus"
  "rpc"
  "rpcuser"
  "haldaemon"
  "apache"
  "postfix"
  "gdm"
  "adiosl"
  "cubrid"
)

LOG_FILE="sulog"
UNAUTH_LOG="unauthorized_su.log"

# 로그 파일의 각 줄을 확인합니다
while read line
do
  # 줄에서 사용자 이름 추출
  username=$(echo $line | awk '{print $1}')

  # 사용자 이름이 허용 목록에 없는지 확인합니다
  if [[ ! "$ALLOWED_USERS" =~ "$username" ]]; then
    # 무단 시도를 기록합니다
    echo "$line" >> $UNAUTH_LOG
  fi
done < $LOG_FILE

# /var/log/xferlog 파일이 이미 있는지 확인하십시오
if [ -e "/var/log/xferlog" ]; then
  OK "/var/log/xferlog가 이미 있습니다."
else
  WARN "/var/log/xferlog가 없습니다."
fi

# /var/log/xferlog 파일 생성
touch /var/log/xferlog

# 파일에 대한 적절한 사용 권한 및 소유권 설정
chmod 644 /var/log/xferlog
chown root:root /var/log/xferlog

cat $result

echo ; echo