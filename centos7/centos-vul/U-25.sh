#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

> $TMP1  

 

BAR

CODE [U-25] NFS 서비스 접근 통제 '확인 필요'

cat << EOF >> $result

[양호]: 불필요한 NFS 서비스가 비활성화 되어있는 경우

[취약]: 불필요한 NFS 서비스가 활성화 되어있는 경우

EOF

BAR

 
#!/bin/bash

if grep -q -E '^[^#].*\s+everyone(?!.*no_root_squash)' /etc/exports; then
    WARN "NFS는 '모두' 그룹에 대한 제한 없이 수출을 공유하고 있습니다"
else
    OK "NFS는 '모두' 그룹에 대한 제한 없이 수출을 공유하지 않습니다."
fi


cat $result

echo ; echo