#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="계정 관리"
code="U-09"
riskLevel="중"
diagnosisItem="계정이 존재하지 않는 GID 금지"
diagnosisResult=""
status=""

# 초기 1줄 기록 (형태 유지)
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 기본 시스템 그룹 (제외)
#########################################
system_groups=(
root bin daemon sys adm tty disk lp mail news uucp man nobody
nogroup wheel utmp games ftp
)

불필요그룹=()
현황=()

#########################################
# passwd GID 목록
#########################################
used_gids=$(awk -F: '{print $4}' /etc/passwd | sort -u)

#########################################
# group 점검
#########################################
while IFS=: read -r gname x gid members; do

    # 시스템 기본 그룹 제외
    for sg in "${system_groups[@]}"; do
        if [[ "$gname" == "$sg" ]]; then
            continue 2
        fi
    done

    # 사용자 primary gid 사용 여부
    if echo "$used_gids" | grep -qw "$gid"; then
        continue
    fi

    # 그룹 멤버 존재 여부
    if [[ -n "$members" ]]; then
        continue
    fi

    # 여기 오면 미사용 그룹
    불필요그룹+=("$gname(gid:$gid)")

done < /etc/group

#########################################
# 결과 판정

if [ ${#불필요그룹[@]} -gt 0 ]; then
    diagnosisResult="취약"

    sample=$(printf '%s\n' "${불필요그룹[@]}" | head -15)
    status="미사용 그룹 존재: $(echo $sample | tr '\n' ' ')"
else
    diagnosisResult="양호"
    status="불필요 그룹 없음"
fi

#########################################
# CSV 기록

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
