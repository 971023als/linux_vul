#!/bin/bash

. function.sh 

BAR

CODE [U-43] 로그의 정기적 검토 및 보고

cat << EOF >> $result

[양호]: 로그 기록의 검토, 분석, 리포트 작성 및 보고 등이 정기적으로 이루어지는 경우

[취약]: 로그 기록의 검토, 분석, 리포트 작성 및 보고 등이 정기적으로 이루어지지 않는 경우는 경우

EOF

BAR

# 로그 파일의 경로 정의
LOG_DIR="/var/log"
UTMP="$LOG_DIR/utmp"
WTMP="$LOG_DIR/wtmp"
BTMP="$LOG_DIR/btmp"

# 로그 파일이 있는지 확인합니다
if [ ! -f "$UTMP" ]; then
  WARN "$UTMP 가 없습니다"
else
  OK "$UTMP 가 있습니다"
fi

if [ ! -f "$WTMP" ]; then
  WARN "$WTMP 가 없습니다"
else
  OK "$WTMP 가 있습니다"
fi

if [ ! -f "$BTMP" ]; then
  WARN "$BTMP 가 없습니다"
else
  OK "$BTMP 가 있습니다"
fi

# '마지막' 명령을 사용하여 로그 정보를 표시
last -f "$WTMP"

# 해킹 시도 증거 'btmp' 파일 내용 확인
cat "$BTMP" | awk '{print $1, $2, $3, $4, $5}'

# 추가 분석을 위해 결과를 파일로 출력
echo "Last login information:" > log_review.txt
last -f "$WTMP" >> log_review.txt
echo "Failed login attempts:" >> log_review.txt
echo "Brute force login attempts:" >> log_review.txt
cat "$BTMP" | awk '{print $1, $2, $3, $4, $5}' >> log_review.txt


SULOG_FILE="/var/log/sulog"
ALLOWED_ACCOUNTS=(
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

while read line; do
  username=$(echo $line | awk '{print $1}')
  granted=$(echo $line | awk '{print $3}')
  if [ "$granted" != "to" ]; then
    continue
  fi

  granted_to=$(echo $line | awk '{print $4}')
  if [[ $ALLOWED_ACCOUNTS =~ (^|[[:space:]])"$granted_to"($|[[:space:]]) ]]; then
    OK "권한을 $granted_to 로 $username 만큼 증가할 수 있습니다."
  else
    WARN "권한을 $granted_to 로 $username 은(는) 허용되지 않습니다."
  fi
done < $SULOG_FILE

XFERLOG="/var/log/xferlog"

# xferlog 파일이 있는지 확인합니다
if [ -f $XFERLOG ]; then
  # awk를 사용하여 xferlog 파일의 각 라인에 대한 IP 주소, 로그인 이름 및 액세스 날짜를 인쇄합니다
  awk '{print $9 " " $10 " " $1}' $XFERLOG | while read line
  do
    # 각 라인에서 IP 주소, 로그인 이름 및 액세스 날짜 추출
    IP=$(echo $line | awk '{print $1}')
    USER=$(echo $line | awk '{print $2}')
    DATE=$(echo $line | awk '{print $3}')
  
    # 로그인 이름이 허용된 계정 목록에 없는지 확인합니다
    if ! grep -q $USER /etc/ftpusers; then
      # 무단 FTP 액세스에 대한 경고 메시지 인쇄
      WARN "$DATE 의 사용자 $USER 에 대한 IP $IP 에서 인증되지 않은 FTP 액세스가 탐지됨"
    else
      OK "$DATE 의 사용자 $USER 에 대한 IP $IP 에서 인증되지 않은 FTP 액세스가 탐지 안 됨"
    fi
  done
else
  # xferlog 파일이 없는 경우 오류 메시지 인쇄
  WARN "xferlog 파일 $XFERLOG 를 찾을 수 없습니다"
fi

cat $result

echo ; echo


 
