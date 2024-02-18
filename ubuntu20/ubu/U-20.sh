#!/bin/bash

. function.sh

BAR

CODE [U-20] Anonymous FTP 비활성화

cat << EOF >> $result

[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우

[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않은 경우

EOF

BAR  

ftp_account="ftp"

# 일반 FTP - Anonymous FTP 접속 제한 설정 방법
sudo userdel ftp

# vsftpd.conf 파일의 경로 설정
vsftpd_conf_file="/etc/vsftpd.conf"

# vsftpd.conf 파일이 있는지 확인합니다
if [ -f $vsftpd_conf_file ]; then
  # anonymous_enable 줄 제거(존재하는 경우)
  sed -i '/^anonymous_enable/d' $vsftpd_conf_file

  # 값이 없는 anonymous_enable 행을 추가합니다
  echo "anonymous_enable=NO" >> $vsftpd_conf_file
else
  # 파일을 찾을 수 없음
  INFO " $vsftpd_conf_file 을 찾을 수 없습니다."
fi

cat $result

echo ; echo