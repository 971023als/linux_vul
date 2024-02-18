#!/bin/bash

. function.sh

BAR

CODE [U-40] 웹서비스 파일 업로드 및 다운로드 제한

cat << EOF >> $result

[양호]: 파일 업로드 및 다운로드를 제한한 경우

[취약]: 파일 업로드 및 다운로드를 제한하지 않은 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

#@@@@@파일크기 5000000으로 할지 아래처럼 할지 확인

# 파일 크기 제한 설정(바이트)
limit=1048576

# 모든 집합 디렉토리에 LimitRequestBody 지시어 추가
# R[Directory_Path]를 실제 디렉토리 경로로 바꿉니다
echo "
<Directory [Directory_Path]>
    LimitRequestBody $limit
</Directory>" >> /etc/apache2/apache2.conf


cat $result

echo ; echo