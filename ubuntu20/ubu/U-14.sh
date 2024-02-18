#!/bin/bash

. function.sh

BAR

CODE [U-14] 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정		

cat << EOF >> $result

[양호]: 홈 디렉터리 환경변수 파일 소유자가 root 또는, 해당 계정으로 지정되
어 있고, 홈 디렉터리 환경변수 파일에 root와 소유자만 쓰기 권한이 부여
된 경우

[취약]: 홈 디렉터리 환경변수 파일 소유자가 root 또는, 해당 계정으로 지정되
지 않고, 홈 디렉터리 환경변수 파일에 root와 소유자 외에 쓰기 권한이 
부여된 경우

EOF

BAR

files=(".profile" ".kshrc" ".cshrc" ".bashrc" ".bash_profile" ".login" ".exrc" ".netrc")

for file in "${files[@]}"; do
  if [ ! -f $file ]; then
    INFO "$file 이 없습니다."
    continue
  fi

  owner=$(stat -c '%U' $file)
  if [ "$owner" != "root" ] && [ "$owner" != "$USER" ]; then
    INFO "$file 소유자를 $USER 로 변경 중..."
    chown $USER $file
  fi

  permission=$(stat -c '%a' $file)
  if [ "$permission" != "600" ] && [ "$permission" != "700" ]; then
    INFO "$file 의 권한을 700으로 변경하는 중..."
    chmod 700 $file
  fi
done

cat $result

echo ; echo
