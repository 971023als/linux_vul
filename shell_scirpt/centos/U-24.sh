#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="파일 및 디렉토리 관리"
code="U-24"
riskLevel="상"
diagnosisItem="사용자 환경변수 파일 소유자 및 권한 설정"
diagnosisResult=""
status=""

# 초기 1줄 기록
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 환경파일 목록
#########################################
env_files=(
".profile"
".kshrc"
".cshrc"
".bashrc"
".bash_profile"
".bash_login"
".login"
".exrc"
".netrc"
)

취약내용=()
vuln=false

#########################################
# passwd 기반 사용자 홈 조회
#########################################
while IFS=: read -r user pass uid gid desc home shell; do

    # 로그인 불가 계정 skip
    if [[ "$shell" == *nologin || "$shell" == *false ]]; then
        continue
    fi

    # 홈 없으면 skip
    [ ! -d "$home" ] && continue

    for f in "${env_files[@]}"; do
        file="$home/$f"
        [ ! -f "$file" ] && continue

        owner=$(stat -c "%U" "$file" 2>/dev/null)
        perm=$(stat -c "%a" "$file" 2>/dev/null)

        # 소유자 체크
        if [[ "$owner" != "$user" && "$owner" != "root" ]]; then
            취약내용+=("$file 소유자 비정상:$owner")
            vuln=true
        fi

        # other write 체크
        if [[ $((perm % 10)) -ge 2 ]]; then
            취약내용+=("$file other write:$perm")
            vuln=true
        fi

        # group write 체크
        if [[ $(((perm / 10) % 10)) -ge 2 ]]; then
            취약내용+=("$file group write:$perm")
            vuln=true
        fi

    done

done < /etc/passwd

#########################################
# 결과 판정
#########################################
if $vuln; then
    diagnosisResult="취약"
    sample=$(printf '%s\n' "${취약내용[@]}" | head -20)
    status=$(echo $sample | tr '\n' ' ')
else
    diagnosisResult="양호"
    status="환경변수 파일 소유자 및 권한 양호"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
