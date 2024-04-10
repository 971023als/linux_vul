#!/bin/bash

# 변수 설정
분류="시스템 설정"
코드="U-20"
위험도="상"
진단_항목="Anonymous FTP 비활성화"
대응방안="[양호]: Anonymous FTP (익명 ftp) 접속을 차단한 경우\n[취약]: Anonymous FTP (익명 ftp) 접속을 차단하지 않은 경우"
현황=()

# /etc/passwd에서 ftp 사용자 확인
if grep -q "^ftp:" /etc/passwd; then
    진단_결과="취약"
    현황+=("FTP 계정이 /etc/passwd 파일에 있습니다.")
else
    진단_결과="양호"
    현황+=("FTP 계정이 /etc/passwd 파일에 없습니다.")
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
for item in "${현황[@]}"; do
    echo "$item"
done
