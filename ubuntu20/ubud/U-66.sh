#!/bin/bash

 

. function.sh
   

BAR

CODE [U-66] SNMP 서비스 구동 점검

cat << EOF >> $result

[양호]: SNMP 서비스를 사용하지 않는 경우

[취약]: SNMP 서비스를 사용하는 경우

EOF

BAR



INFO "이 부분은 백업 파일 관련한 항목이 아닙니다"

#---------------------------------------------------

# Start the snmpd service
sudo service snmpd start

INFO "SNMP 서비스를 시작하였습니다."

cat $result

echo ; echo
 

