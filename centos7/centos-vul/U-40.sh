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

 

# Set the Apache2 configuration file path
config_file="/etc/httpd/conf/httpd.conf"

# Use grep to check if the LimitRequestBody, LimitXMLRequestBody and LimitUploadSize options are enabled in the configuration file
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