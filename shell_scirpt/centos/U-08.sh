#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="계정 관리"
code="U-08"
riskLevel="상"
diagnosisItem="관리자 그룹 최소 계정"
diagnosisResult=""
status=""

# 초기 1줄 기록 (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 관리자 그룹 정의
#########################################
admin_groups=("root" "wheel" "admin")

불필요계정=()
현황=()

#########################################
# UID 0 계정 목록
#########################################
uid0_accounts=$(awk -F: '$3==0 {print $1}' /etc/passwd)

#########################################
# 그룹 점검
#########################################
for grp in "${admin_groups[@]}"; do
    if grep -q "^$grp:" /etc/group; then
        members=$(grep "^$grp:" /etc/group | awk -F: '{print $4}')

        if [[ -n "$members" ]]; then
            IFS=',' read -ra users <<< "$members"

            for u in "${users[@]}"; do
                [[ -z "$u" ]] && continue

                # UID0 아닌 관리자계정
                if ! echo "$uid0_accounts" | grep -qw "$u"; then
                    불필요계정+=("$u($grp 그룹)")
                fi
            done
        fi
    fi
done

#########################################
# 결과 판정
#########################################
if [ ${#불필요계정[@]} -gt 0 ]; then
    diagnosisResult="취약"

    sample=$(printf '%s\n' "${불필요계정[@]}" | head -10)
    status="관리자 그룹 불필요 계정: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="관리자 그룹 최소 계정 유지"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
