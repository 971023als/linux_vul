#!/bin/bash

. function.sh

BAR

CODE [U-38] 웹서비스 불필요한 파일 제거

cat << EOF >> $result

[양호]: 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되어 있는 경우

[취약]: 기본으로 생성되는 불필요한 파일 및 디렉터리가 제거되지 않은 경우 

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  


BACKUP_DIR="/backup_invalid_owners"
BACKUP_FILE="apache_backup.tar.gz"
HTTPD_ROOT="/etc/apache2/"

# 백업 
tar -czvf $BACKUP_DIR$BACKUP_FILE $HTTPD_ROOT

# 백업
if tar -czvf "$BACKUP_DIR$BACKUP_FILE" "$HTTPD_ROOT"; then
  OK "백업 파일 $BACKUP_FILE이 $BACKUP_DIR에 생성되었습니다."
else
  WARN "백업 파일 생성에 실패하였습니다."
fi

#--------------------------------------------------------------

BACKUP_DIR="/backup_invalid_owners"
BACKUP_FILE="apache_backup.tar.gz"
HTTPD_ROOT="/etc/apache2/"

# HTTPD_ROOT에 백업 파일 압축 풀기
tar -xzf $BACKUP_DIR$BACKUP_FILE -C $HTTPD_ROOT


# HTTPD_ROOT에 백업 파일 압축 풀기
if [ -f "$BACKUP_DIR$BACKUP_FILE" ]; then
  if tar -xzf "$BACKUP_DIR$BACKUP_FILE" -C "$HTTPD_ROOT"; then
    OK "백업 파일 $BACKUP_FILE이 $HTTPD_ROOT에 압축 해제되었습니다."
  else
    WARN "백업 파일 $BACKUP_FILE 압축 해제에 실패하였습니다."
  fi
else
  INFO "백업 파일 $BACKUP_FILE이 $BACKUP_DIR 디렉토리 내에 존재하지 않습니다."
fi


cat $result

echo ; echo