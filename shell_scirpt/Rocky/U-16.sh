#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-16"
위험도="상"
진단_항목="/dev에 존재하지 않는 device 파일 점검"
대응방안="/dev에 대한 파일 점검 후 존재하지 않은 device 파일을 제거한 경우"
dev_directory='/dev'
non_device_files=()
진단_결과=""

# /dev 디렉터리 검사
for item in "$dev_directory"/*; do
    if [ -f "$item" ]; then
        # 파일이 캐릭터 또는 블록 디바이스가 아닌 경우 목록에 추가
        if [ ! -c "$item" ] && [ ! -b "$item" ]; then
            non_device_files+=("$item")
        fi
    fi
done

# 진단 결과 결정 및 현황 업데이트
if [ ${#non_device_files[@]} -gt 0 ]; then
    진단_결과="취약"
    현황=("다음 파일들이 /dev에 존재하지 않는 장치 파일로 발견되었습니다: ${non_device_files[*]}")
else
    진단_결과="양호"
    현황=("/dev 디렉터리에 존재하지 않는 device 파일이 없습니다.")
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
