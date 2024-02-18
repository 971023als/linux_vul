#!/bin/bash

. function.sh

BAR

CODE [U-13] SUID,SGID,Sticky bit 설정파일 점검 

cat << EOF >> $result

[양호]: 주요 파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있지 않은 경우

[취약]: 주요 파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있는 경우

EOF

BAR

# /etc/passwd 파일을 읽고 홈 디렉토리 정보 추출
while IFS=: read -r username passwd uid gid name home shell
do
  # 홈 디렉토리에서 기본 실행 파일의 사용 권한 정보를 가져옵니다
  main_exec=$(find / -user root -type f \( -perm -04000 -o -perm -02000 \) -exec ls -al {} \;)

  # 주 실행 파일이 존재하는 경우
  if [ -n "$main_exec" ]; then
    # 권한 정보를 가져옵니다
    permissions=$(ls -ld "$main_exec" | awk '{print $1}')
    owner=$(ls -ld "$main_exec" | awk '{print $3}')
    group=$(ls -ld "$main_exec" | awk '{print $4}')

    # 파일에 SUID 또는 SGID 사용 권한이 있는지 확인합니다
    if [ -u "$main_exec" ]; then
      WARN "$main_exec SUID 권한이 탐지됨"
    elif [ -g "$main_exec" ]; then
      WARN "$main_exec SGID 권한이 파일에서 탐지됨"
    else
      OK "$main_exec SUID와 SGID에 대한 설정이 부여"
    fi
  fi
done < /etc/passwd

cat $result

echo ; echo

 
