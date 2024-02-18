#!/bin/bash

 

. function.sh


TMP1=`SCRIPTNAME`.log

> $TMP1  

BAR

CODE [U-67] SNMP 서비스 Community String의 복잡성 설정

cat << EOF >> $result

[양호]: SNMP Community 이름이 public, private 이 아닌 경우

[취약]: SNMP Community 이름이 public, private 인 경우

EOF

BAR

snmpd_config_file="/etc/snmp/snmpd.conf"

# snmpd.conf 파일에서 커뮤니티 이름 검색
communities=$(grep -E '^community' $snmpd_config_file | cut -d ' ' -f 2)

# snmpd.conf 파일이 있는지 확인합니다
if [ ! -f $snmpd_config_file ]; then
  INFO "snmpd.conf 파일이 없습니다. 확인해주세요."
else
  for community in $communities; do
    if [ $community == "public" ] || [ $community == "private" ]; then
      WARN "Community name $community 는 허용되지 않습니다."
    else
      OK "Community name $community 는 허용되고 있습니다." 
    fi
  done
fi

cat $result

echo ; echo 
