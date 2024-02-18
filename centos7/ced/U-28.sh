#!/bin/bash

. function.sh

BAR

CODE [U-28] NIS , NIS+ 점검		

cat << EOF >> $result

[양호]: NIS 서비스가 비활성화 되어 있거나, 필요 시 NIS+를 사용하는 경우

[취약]: NIS 서비스가 활성화 되어 있는 경우

EOF

BAR

INFO "이 부분은 백업 파일 관련한 항목이 아닙니다"

#---------------------------------------------------

sudo service ypserv start
sudo update-rc.d ypserv enable

sudo service ypbind start
sudo update-rc.d ypbind enable

sudo service ypxfrd start
sudo update-rc.d ypxfrd enable

sudo service rpc.yppasswdd start
sudo update-rc.d rpc.yppasswdd enable

sudo service rpc.ypupdated start
sudo update-rc.d rpc.ypupdated enable

cat $result

echo ; echo
