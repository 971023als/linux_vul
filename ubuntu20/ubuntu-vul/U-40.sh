#!/bin/bash

 

. function.sh

 
TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-40] Apache 파일 업로드 및 다운로드 제한 

cat << EOF >> $result

[양호]: 파일 업로드 및 다운로드를 제한한 경우

[취약]: 파일 업로드 및 다운로드를 제한하지 않은 경우

EOF

BAR

 

# 확인할 Apache2 Document Root 디렉토리 설정
config_file="/etc/apache2/apache2.conf"

# grep을 사용하여 구성 파일에서 파일 업로드 다운로드 제한되었는지 확인합니다
upload_result=$(grep -E "^[ \t]*LimitRequestBody" $config_file)
download_result=$(grep -E "^[ \t]*LimitXMLRequestBody" $config_file)
upload_size_result=$(grep -E "^[ \t]*LimitUploadSize" $config_file)

if [ -n "$upload_result" ] || [ -n "$download_result" ] || [ -n "$upload_size_result" ] ; then
    OK "Apache2에서 파일 업로드 및 다운로드가 제한됩니다"
else
    WARN "Apache2에서 파일 업로드 및 다운로드가 제한되지 않습니다."
fi

cat $result

echo ; echo