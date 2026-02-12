#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-20"
riskLevel="상"
diagnosisItem="/etc/(x)inetd.conf 파일 소유자 및 권한 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 점검 대상 파일
#########################################
files=(
"/etc/inetd.conf"
"/etc/xinetd.conf"
"/etc/systemd/system.conf"
)

dirs=(
"/etc/xinetd.d"
)

취약내용=()
vuln=false

#########################################
# 파일 점검
#########################################
check_file() {
    local f="$1"

    [ ! -f "$f" ] && return

    owner=$(stat -c "%U" "$f" 2>/dev/null)
    perm=$(stat -c "%a" "$f" 2>/dev/null)

    if [[ "$owner" != "root" ]]; then
        취약내용+=("$f 소유자 root 아님:$owner")
        vuln=true
    fi

    if [[ "$perm" -gt 600 ]]; then
        취약내용+=("$f 권한 600 초과:$perm")
        vuln=true
    fi
}

#########################################
# 디렉터리 내 파일 점검
#########################################
check_dir() {
    local d="$1"
    [ ! -d "$d" ] && return

    while IFS= read -r file; do
        check_file "$file"
    done < <(find "$d" -type f 2>/dev/null)
}

#########################################
# 점검 수행
#########################################
for f in "${files[@]}"; do
    check_file "$f"
done

for d in "${dirs[@]}"; do
    check_dir "$d"
done

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${취약내용[*]}")
else
    diagnosisResult="양호"
    status="inetd/xinetd/systemd 설정 파일 권한 양호"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
