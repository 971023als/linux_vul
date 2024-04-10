#!/bin/bash

# 변수 초기화
분류="계정 관리"
코드="U-04"
위험도="상"
진단_항목="패스워드 파일 보호"
대응방안="쉐도우 패스워드 사용 또는 패스워드 암호화 저장"
현황=()
진단_결과=""

passwd_file="/etc/passwd"
shadow_file="/etc/shadow"
shadow_used=true  # 가정: 쉐도우 패스워드 사용

# /etc/passwd 파일에서 쉐도우 패스워드 사용 여부 확인
if [ -f "$passwd_file" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        IFS=':' read -r -a parts <<< "$line"
        if [ "${#parts[@]}" -gt 1 ] && [ "${parts[1]}" != "x" ]; then
            shadow_used=false
            break
        fi
    done < "$passwd_file"
fi

# /etc/shadow 파일 존재 및 권한 검사
if $shadow_used && [ -f "$shadow_file" ]; then
    if [ ! -r "$shadow_file" ]; then  # /etc/shadow가 읽기 전용으로 설정되어 있는지 확인
        현황+=("/etc/shadow 파일이 안전한 권한 설정을 갖고 있지 않습니다.")
        shadow_used=false
    fi
fi

if ! $shadow_used; then
    현황+=("쉐도우 패스워드를 사용하고 있지 않거나 /etc/shadow 파일의 권한 설정이 적절하지 않습니다.")
    진단_결과="취약"
else
    현황+=("쉐도우 패스워드를 사용하고 있으며 /etc/shadow 파일의 권한 설정이 적절합니다.")
    진단_결과="양호"
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
echo "현황:"
for 사항 in "${현황[@]}"; do
    echo "- $사항"
done
