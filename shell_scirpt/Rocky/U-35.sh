#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-35"
위험도="상"
진단항목="웹서비스 디렉토리 리스팅 제거"
진단결과=""
현황=()
대응방안="디렉터리 검색 기능 사용하지 않기"
vulnerable=0

# 웹 구성 파일 목록
webconf_files=(".htaccess" "httpd.conf" "apache2.conf" "userdir.conf")

# 웹 구성 파일 검사
for conf_file in "${webconf_files[@]}"; do
    find_output=$(find / -name $conf_file -type f 2>/dev/null)
    IFS=$'\n' # find 명령어의 출력을 줄 단위로 분리
    for file_path in $find_output; do
        if [ -n "$file_path" ]; then
            if grep -qi "options indexes" "$file_path" && ! grep -qi "-indexes" "$file_path"; then
                if [ "$conf_file" == "userdir.conf" ]; then
                    if ! grep -qi "userdir disabled" "$file_path"; then
                        vulnerable=1
                        현황+=("$file_path 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다.")
                        break 2
                    fi
                else
                    vulnerable=1
                    현황+=("$file_path 파일에 디렉터리 검색 기능을 사용하도록 설정되어 있습니다.")
                    break 2
                fi
            fi
        fi
    done
done

# 진단 결과 설정
if [ $vulnerable -eq 0 ]; then
    진단결과="양호"
    현황+=("웹서비스 디렉터리 리스팅이 적절히 제거되었습니다.")
else
    진단결과="취약"
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
