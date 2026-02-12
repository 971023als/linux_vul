#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-40"
riskLevel="상"
diagnosisItem="NFS 접근 통제 설정"
diagnosisResult=""
status=""

# 초기 1줄
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
vuln=false
현황=()
nfs_used=false

#########################################
# NFS 사용 여부 확인
#########################################
if systemctl is-active nfs-server 2>/dev/null | grep -q active; then
    nfs_used=true
fi

if ps -ef | grep nfsd | grep -v grep >/dev/null; then
    nfs_used=true
fi

#########################################
# NFS 미사용
#########################################
if ! $nfs_used; then
    diagnosisResult="양호"
    status="NFS 서비스 미사용"
else

#########################################
# exports 파일 점검
#########################################
if [ -f /etc/exports ]; then

    perm=$(stat -c "%a" /etc/exports 2>/dev/null)
    owner=$(stat -c "%U" /etc/exports 2>/dev/null)

    # 권한
    if (( perm > 644 )); then
        vuln=true
        현황+=("/etc/exports 권한취약:$perm")
    fi

    if [[ "$owner" != "root" ]]; then
        vuln=true
        현황+=("/etc/exports 소유자root아님")
    fi

    while read -r line; do
        [[ "$line" =~ ^# ]] && continue
        [[ -z "$line" ]] && continue

        # everyone 공유
        if echo "$line" | grep '\*' >/dev/null; then
            vuln=true
            현황+=("everyone(*) 공유 존재")
        fi

        # no_root_squash
        if echo "$line" | grep "no_root_squash" >/dev/null; then
            vuln=true
            현황+=("no_root_squash 사용")
        fi

    done < /etc/exports

else
    vuln=true
    현황+=("exports 파일 없음")
fi

#########################################
# 결과
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="NFS 접근통제 설정 양호"
fi

fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
