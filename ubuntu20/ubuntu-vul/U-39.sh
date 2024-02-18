#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1 
 

BAR

CODE [U-39] Apache 링크 사용 금지 

cat << EOF >> $result

[양호]: 심볼릭 링크, aliases 사용을 제한한 경우

[취약]: 심볼릭 링크, aliases 사용을 제한하지 않은 경우

EOF

BAR

# 확인할 Apache2 Document Root 디렉토리 설정
config_file="/etc/apache2/apache2.conf"

# grep을 사용하여 구성 파일에서 FollowSymLinks 및 SymLinksIfOwnerMatch 옵션이 실행되었는지 확인합니다
symlink_result=$(grep -E "^[ \t]*Options[ \t]+FollowSymLinks" $config_file)
alias_result=$(grep -E "^[ \t]*Options[ \t]+SymLinksIfOwnerMatch" $config_file)

if [ -n "$symlink_result" ] && [ -n "$alias_result" ]; then
    WARN "Apache2에서 심볼릭 링크 및 별칭이 허용됨"
else
    OK "Apache2에서는 심볼릭 링크 및 별칭이 제한됩니다."
fi

 
cat $result

echo ; echo


 
