#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-36"
riskLevel="상"
diagnosisItem="r 계열 서비스 비활성화"
diagnosisResult=""
status=""

# 초기 1줄
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#########################################
# 변수
#########################################
vuln=false
현황=()

#########################################
# 1. inetd.conf r 서비스 확인
#########################################
if [ -f /etc/inetd.conf ]; then
    if grep -Ei "rsh|rlogin|rexec|shell|login|exec" /etc/inetd.conf | grep -v '^#' >/dev/null; then
        vuln=true
        현황+=("inetd r-service 활성")
    fi
fi

#########################################
# 2. xinetd 확인
#########################################
for svc in rsh rlogin rexec; do
    if [ -f /etc/xinetd.d/$svc ]; then
        if grep -Ei "disable\s*=\s*no" /etc/xinetd.d/$svc >/dev/null; then
            vuln=true
            현황+=("xinetd $svc 활성")
        fi
    fi
done

#########################################
# 3. systemd 확인
#########################################
if systemctl list-unit-files 2>/dev/null | grep -Ei "rlogin|rexec|rsh" >/dev/null; then
    if systemctl list-units --type=service --state=running 2>/dev/null | grep -Ei "rlogin|rexec|rsh" >/dev/null; then
        vuln=true
        현황+=("systemd r-service 실행중")
    fi
fi

#########################################
# 4. 포트 확인 (512 513 514)
#########################################
if ss -lntup 2>/dev/null | grep -E ":512 |:513 |:514 " >/dev/null; then
    vuln=true
    현황+=("r계열 포트 LISTEN(512/513/514)")
fi

#########################################
# 5. hosts.equiv 존재
#########################################
if [ -f /etc/hosts.equiv ]; then
    vuln=true
    현황+=("/etc/hosts.equiv 존재")
fi

#########################################
# 6. 사용자 .rhosts 존재
#########################################
if find /home -name ".rhosts" 2>/dev/null | grep . >/dev/null; then
    vuln=true
    현황+=("사용자 .rhosts 존재")
fi

#########################################
# 결과
#########################################
if $vuln; then
    diagnosisResult="취약"
    status=$(IFS=' | '; echo "${현황[*]}")
else
    diagnosisResult="양호"
    status="r 계열 서비스 비활성화"
fi

#########################################
# CSV 기록
#########################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#########################################
# 출력
#########################################
cat $OUTPUT_CSV
