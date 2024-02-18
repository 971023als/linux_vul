#!/bin/bash

. function.sh

BAR

CODE [U-31] 스팸 메일 릴레이 제한		

cat << EOF >> $result

[양호]: SMTP 서비스를 사용하지 않거나 릴레이 제한이 설정되어 있는 경우

[취약]: SMTP 서비스를 사용하며 릴레이 제한이 설정되어 있지 않은 경우

EOF

BAR

# 파일 경로 지정
file="/etc/mail/sendmail.cf"

# 주석을 제거할 라인 지정
line="R$* $#error $@ 5.7.1 $: \"550 Relaying denied\""

# 라인에서 주석을 제거
sed -i "s/#//" $file

# 라인이 수정되었는지 확인
grep "$line" $file

sed -i '/#R/ s/#//' $file

cat $result

echo ; echo
