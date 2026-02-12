#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="계정 관리"
code="U-11"
riskLevel="중"
diagnosisItem="사용자 shell 점검"
diagnosisResult=""
status=""

# 초기 1줄 기록 (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 점검 대상 계정 목록
#########################################
system_accounts=(
daemon bin sys adm listen nobody nobody4 noaccess
diag operator games gopher lp mail news uucp ftp
)

취약계정=()
현황=()

#########################################
# passwd 점검
#########################################
while IFS=: read -r user pass uid gid desc home shell; do

    for sacc in "${system_accounts[@]}"; do
        if [[ "$user" == "$sacc" ]]; then

            if [[ "$shell" != "/sbin/nologin" && "$shell" != "/bin/false" ]]; then
                취약계정+=("$user($shell)")
            fi

        fi
    done

done < /etc/passwd

#########################################
# 결과 판정
#########################################
if [ ${#취약계정[@]} -gt 0 ]; then
    diagnosisResult="취약"

    sample=$(printf '%s\n' "${취약계정[@]}" | head -10)
    status="로그인 가능 shell 계정: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="시스템 계정 shell 설정 양호"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
