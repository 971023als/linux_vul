#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-31"
위험도="상"
진단_항목="스팸 메일 릴레이 제한"
대응방안="SMTP 서비스 릴레이 제한 설정"
현황=()
search_directory='/etc/mail/'
vulnerable_found=false

# sendmail.cf 파일 검색 및 내용 분석
find "$search_directory" -name 'sendmail.cf' -type f | while read -r file_path; do
    if [ -f "$file_path" ]; then
        if grep -qE 'R\$\*' "$file_path" || grep -qEi 'Relaying denied' "$file_path"; then
            현황+=("$file_path 파일에 릴레이 제한이 적절히 설정되어 있습니다.")
        else
            vulnerable_found=true
            현황+=("$file_path 파일에 릴레이 제한 설정이 없습니다.")
        fi
    fi
done

# 진단 결과 결정
if $vulnerable_found; then
    진단_결과="취약"
else
    if [ ${#현황[@]} -eq 0 ]; then
        진단_결과="양호"
        현황+=("sendmail.cf 파일을 찾을 수 없거나 접근할 수 없습니다.")
    else
        진단_결과="양호"
    fi
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
