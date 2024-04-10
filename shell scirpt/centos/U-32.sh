#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-32"
위험도="상"
진단_항목="일반사용자의 Sendmail 실행 방지"
대응방안="SMTP 서비스 미사용 또는 일반 사용자의 Sendmail 실행 방지 설정"
현황=()
restriction_set=false

# sendmail.cf 파일들 찾기 및 restrictqrun 옵션 검사
find / -name 'sendmail.cf' -type f 2>/dev/null | while read -r file_path; do
    if grep -q 'restrictqrun' "$file_path" && ! grep -q '^#' "$file_path"; then
        현황+=("$file_path 파일에 restrictqrun 옵션이 설정되어 있습니다.")
        restriction_set=true
        break # 하나라도 찾으면 나머지 검사 중단
    fi
done

# 진단 결과 결정
if $restriction_set; then
    진단_결과="양호"
    if [ ${#현황[@]} -eq 0 ]; then
        현황+=("모든 sendmail.cf 파일에 restrictqrun 옵션이 적절히 설정되어 있습니다.")
    fi
else
    진단_결과="취약"
    if [ ${#현황[@]} -eq 0 ]; then
        현황+=("sendmail.cf 파일 중 restrictqrun 옵션이 설정되어 있지 않은 파일이 있습니다.")
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
