#!/bin/bash

# 변수 설정
분류="서비스 관리"
코드="U-36"
위험도="상"
진단항목="웹서비스 웹 프로세스 권한 제한"
진단결과=""
현황=()
대응방안="Apache 데몬 root 권한 구동 방지"
found_vulnerability=0

# 웹 구성 파일 목록
webconf_files=(".htaccess" "httpd.conf" "apache2.conf")

# 웹 구성 파일 검사
for conf_file in "${webconf_files[@]}"; do
    while IFS= read -r file_path; do
        if [ -f "$file_path" ]; then
            while IFS= read -r line; do
                if [[ "$line" =~ ^Group && ! "$line" =~ ^# ]]; then
                    group_setting=($line) # 배열로 변환
                    if [ "${#group_setting[@]}" -gt 1 ] && [ "${group_setting[1],,}" == "root" ]; then
                        진단결과="취약"
                        현황+=("$file_path 파일에서 Apache 데몬이 root 권한으로 구동되도록 설정되어 있습니다.")
                        found_vulnerability=1
                        break 2
                    fi
                fi
            done < "$file_path"
        fi
    done < <(find / -name $conf_file -type f 2>/dev/null)
    if [ $found_vulnerability -eq 1 ]; then
        break
    fi
done

# 진단 결과 설정
if [ $found_vulnerability -eq 0 ]; then
    진단결과="양호"
    현황+=("Apache 데몬이 root 권한으로 구동되도록 설정되어 있지 않습니다.")
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
