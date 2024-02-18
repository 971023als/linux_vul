#!/bin/bash

. function.sh

BAR

CODE [U-45] root 계정 su 제한		

cat << EOF >> $result

[양호]: su 명령어를 특정 그룹에 속한 사용자만 사용하도록 제한되어 있는 경우
※ 일반사용자 계정 없이 root 계정만 사용하는 경우 su 명령어 사용제한 불필요

[취약]: su 명령어를 모든 사용자가 사용하도록 설정되어 있는 경우

EOF

BAR


INFO "이 부분은 백업 파일 관련한 항목이 아닙니다"

#---------------------------------------------------

# su 명령에서 SUID 비트 제거
sudo chmod u-s $(which su)

# su 명령에 대한 그룹 제한 제거
sudo chgrp root $(which su)
sudo chmod g+rwx $(which su)
sudo chmod g-rxs $(which su)

INFO "su 명령의 원래 상태가 복원되었습니다."

cat $result

echo ; echo

