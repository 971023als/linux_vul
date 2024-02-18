#!/bin/bash

 

. function.sh
 

BAR

CODE [U-62] ftp 계정 shell 제한

cat << EOF >> $result

[양호]: ftp 계정에 /bin/false 쉘이 부여되어 있는 경우

[취약]: ftp 계정에 /bin/false 쉘이 부여되지 않는 경우

EOF

BAR


TMP1=`SCRIPTNAME`.log

> $TMP1 

# FTP 서비스 중지
service ftp stop

# FTP 서비스 사용 안 함
service ftp disable

# vsftpd 서비스를 중지합니다:
service vsftpd stop

# vsftpd 서비스를 시작하지 않도록 설정합니다
/etc/rc.d/init.d/vsftpd stop

# proftp 서비스를 중지합니다:
service proftp stop

# proftp를 시작하지 않도록 설정합니다
/etc/rc.d/init.d/proftp stop

# /etc/passwd에서 FTP 계정을 확인합니다
ftp_entry=$(grep "^ftp:" /etc/passwd)

# FTP 계정의 셸을 /bin/false로 변경합니다
chsh -s /bin/false ftp

cat $result

echo ; echo 

 
