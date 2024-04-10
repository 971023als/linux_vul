#!/bin/bash

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-15"
위험도="상"
진단_항목="world writable 파일 점검"
대응방안="시스템 중요 파일에 world writable 파일이 존재하지 않거나, 존재 시 설정 이유를 확인"
현황=()
진단_결과=""

# 검사 시작 디렉터리 설정; 경고: '/' 사용 시 시스템 성능에 큰 영향을 줄 수 있음
start_dir='/tmp'  # 전체 시스템 스캔을 위해 변경 가능

# world writable 파일 검색
while IFS= read -r -d '' file; do
    현황+=("$file")
done < <(find "$start_dir" -type f -perm -002 -print0)

# 진단 결과 결정
if [ ${#현황[@]} -eq 0 ]; then
    진단_결과="양호"
    현황+=("world writable 설정이 되어있는 파일이 없습니다.")
else
    진단_결과="취약"
fi

# 결과 출력
echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
echo "현황:"
for item in "${현황[@]}"; do
    echo "- $item"
done
