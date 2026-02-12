#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "분류,코드,위험도,진단항목,대응방안,진단결과,현황" > $OUTPUT_CSV
fi

# 변수 설정
분류="파일 및 디렉터리 관리"
코드="U-15"
위험도="상"
진단항목="world writable 파일 점검"
대응방안="시스템 중요 파일에 world writable 파일이 존재하지 않거나, 존재 시 설정 이유를 확인"
현황=""
진단결과=""

TMP1=$(basename "$0").log
> $TMP1

# 검사 시작 디렉터리 설정; 경고: '/' 사용 시 시스템 성능에 큰 영향을 줄 수 있음
start_dir='/tmp'  # 전체 시스템 스캔을 위해 변경 가능

# world writable 파일 검색
world_writable_files=$(find "$start_dir" -type f -perm -002)

# 진단 결과 결정
if [ -z "$world_writable_files" ]; then
    진단결과="양호"
    현황="world writable 설정이 되어있는 파일이 없습니다."
else
    진단결과="취약"
    현황=$(echo "$world_writable_files" | tr '\n' ', ' | sed 's/, $//')
fi

# 결과를 로그 파일에 기록
echo "현황: $현황" >> $TMP1

# CSV 파일에 결과 추가
echo "$분류,$코드,$위험도,$진단항목,$대응방안,$진단결과,$현황" >> $OUTPUT_CSV

# 로그 파일 출력
cat $TMP1

# CSV 파일 출력
echo ; echo
cat $OUTPUT_CSV
