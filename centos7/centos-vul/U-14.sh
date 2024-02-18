#!/bin/bash

 

. function.sh

TMP1=`SCRIPTNAME`.log

>$TMP1  
 

BAR

CODE [U-14] 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정 

cat << EOF >> $result  

[양호]: 홈 디렉터리 환경변수 파일 소유자가 root 또는 해당 계정으로 지정되어 있고 

홈 디렉터리 환경변수 파일에 root와 소유자만 쓰기 권한이 부여된 경우

[취약]: 홈 디렉터리 환경변수 파일 소유자가 root 또는 해당 계정으로 지정되지 않고 

홈 디렉터리 환경변수 파일에 root와 소유자 외에 쓰기 권한이 부여된 경우

EOF

BAR

files=(".profile" ".kshrc" ".cshrc" ".bashrc" ".bash_profile" ".login" ".exrc" ".netrc")

for file in "${files[@]}"; do

  if [ -f "${file}" ]; then
    owner=$(stat -c '%U' $file)
    if [ "$owner" != "root" ] && [ "$owner" != "$USER" ]; then
      WARN "$file 에 잘못된 소유자($owner), 예상 루트 또는 $USER 가 있습니다."
    else
      OK "$file 에 잘못된 소유자($owner), 예상 루트 또는 $USER 가 있습니다." 
    fi

    permission=$(stat -c '%a' $file)
    if [ "$permission" != "600" ] && [ "$permission" != "700" ]; then
      WARN "$file 에 잘못된 권한($permission)이 있습니다. 600 또는 700이 예상됩니다."
    else
      OK "$file 에 잘못된 소유자($owner), 예상 루트 또는 $USER 가 있습니다." 
    fi
  else
    INFO " $file 을 찾을 수 없습니다"
  fi
done


cat $result

echo ; echo
 
