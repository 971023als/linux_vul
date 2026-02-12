#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더 생성
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-55"
riskLevel="중"
diagnosisItem="FTP 계정 shell 제한"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#############################################
# 변수
#############################################
ftp_accounts=("ftp" "anonymous")
safe_shells=("/sbin/nologin" "/bin/false" "/usr/sbin/nologin")
ftp_service_running=false
vuln=false
현황=()

#############################################
# 1. FTP 서비스 사용 여부
#############################################
if ps -ef | egrep "vsftpd|proftpd|pure-ftpd" | grep -v grep >/dev/null; then
    ftp_service_running=true
fi

#############################################
# 2. FTP 서비스 미사용 → 양호
#############################################
if ! $ftp_service_running; then
    diagnosisResult="양호"
    status="FTP 서비스 미사용"
else

    #############################################
    # 3. FTP 계정 shell 점검
    #############################################
    for acct in "${ftp_accounts[@]}"; do
        user_info=$(grep "^$acct:" /etc/passwd)

        if [ -n "$user_info" ]; then
            shell=$(echo "$user_info" | awk -F: '{print $7}')
            safe=false

            for s in "${safe_shells[@]}"; do
                if [[ "$shell" == "$s" ]]; then
                    safe=true
                    break
                fi
            done

            if ! $safe; then
                vuln=true
                현황+=("$acct 계정 shell 취약: $shell")
            else
                현황+=("$acct 계정 shell 안전: $shell")
            fi
        fi
    done

    #############################################
    # 결과
    #############################################
    if $vuln; then
        diagnosisResult="취약"
        status=$(IFS=' | '; echo "${현황[*]}")
    else
        diagnosisResult="양호"
        status=$(IFS=' | '; echo "${현황[*]}")
    fi
fi

#############################################
# CSV 기록
#############################################
echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,\"$status\"" >> $OUTPUT_CSV

#############################################
# 출력
#############################################
cat $OUTPUT_CSV
