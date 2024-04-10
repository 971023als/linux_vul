#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-37"
위험도="상"
진단항목="웹서비스 상위 디렉토리 접근 금지"
진단결과=""
현황=()
대응방안="상위 디렉터리에 이동제한 설정"
found_vulnerability=0

# 웹 구성 파일 목록
webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")

# 웹 구성 파일 검사
for conf_file in "${webconf_files[@]}"; do
    while IFS= read -r file_path; do
        if [ -f "$file_path" ]; then
            if ! grep -q "AllowOverride None" "$file_path"; then
                found_vulnerability=1
                진단결과="취약"
                현황+=("$file_path 파일에 상위 디렉터리 접근 제한 설정이 없습니다.")
                break
            fi
        fi
    done < <(find / -name $conf_file -type f 2>/dev/null)
    if [ $found_vulnerability -eq 1 ]; then
        break
    fi
done

# 진단 결과 설정
if [ $found_vulnerability -eq 0 ]; then
    진단결과="양호"
    현황+=("웹서비스 상위 디렉터리 접근에 대한 제한이 적절히 설정되어 있습니다.")
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단항목"
echo "진단 결과: $진단결과"
echo "현황:"
for 상태 in "${현황[@]}"; do
    echo "- $상태"
done
echo "대응방안: $대응방안"
