#!/bin/bash

. function.sh

BAR

CODE [U-05] root홈, 패스 디렉터리 권한 및 패스 설정

cat << EOF >> $result

[양호]: PATH 환경변수에 “.” 이 맨 앞이나 중간에 포함되지 않은 경우

[취약]: PATH 환경변수에 “.” 이 맨 앞이나 중간에 포함되어 있는 경우

EOF

BAR

TMP1=`SCRIPTNAME`.log

>$TMP1  

# PATH의 현재 값을 가져옴
path=$(echo $PATH)

# 시작 부분에 "." 또는 ":"가 있는지 확인
if [[ "${path:0:1}" == "." || "${path:0:1}" == ":" ]]; then
  # 첫 번째 문자("." 또는 ":")를 처음부터 제거합니다
  path="${path:1}"
fi

# 경로를 배열로 분할
path_array=($(echo $path | tr ":" "\n"))

# 배열에서 "."의 색인을 찾음
index=0
for i in "${!path_array[@]}"; do
  if [[ "${path_array[i]}" == "." ]]; then
    index=$i
    break
  fi
done

# 배열에서 "."를 제거하고 끝에 추가
unset 'path_array[index]'
path_array+=(".")

# 배열을 ":" 구분 기호를 사용하여 문자열로 다시 조인
new_path=$(IFS=:; echo "${path_array[*]}")

# PATH 환경 변수 업데이트
echo "PATH=$new_path" >> ~/.profile
echo "PATH=$new_path" >> /etc/profile

# 환경 변수 다시 로드
source ~/.profile
source /etc/profile

cat $result

echo ; echo