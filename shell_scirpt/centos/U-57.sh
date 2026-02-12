#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-57"
riskLevel="중"
diagnosisItem="ftpusers 파일 설정 (root FTP 접속 제한)"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#############################################
# 변수
#############################################
ftp_running=false
root_blocked=false
현황=()

#############################################
# 1. FTP 서비스 실행 여부
#############################################
if ps -ef | egrep "vsftpd|proftpd|pure-ftpd" | grep -v grep >/dev/null; then
    ftp_running=true
fi

if ss -lntup 2>/dev/null | grep ":21 " >/dev/null; then
    ftp_running=true
fi

#############################################
# 2. FTP 미사용 → 양호
#############################################
if ! $ftp_running; then
    diagnosisResult="양호"
    status="FTP 서비스 미사용"

else

    #############################################
    # 3. ftpusers 파일 검사
    #############################################
    ftpusers_files=(
        "/etc/ftpusers"
        "/etc/vsftpd/ftpusers"
        "/etc/vsftpd/user_list"
    )

    for file in "${ftpusers_files[@]}"; do
        if [ -f "$file" ]; then
            if grep -E '^root' "$file" | grep -v '^#' >/dev/null; then
                root_blocked=true
                현황+=("$file root 접속 차단 설정")
            else
                현황+=("$file root 차단 설정 없음")
            fi
        fi
    done

    #############################################
    # 4. vsftpd 설정 확인
    #############################################
    vsftp_conf=(
        "/etc/vsftpd.conf"
        "/etc/vsftpd/vsftpd.conf"
    )

    for conf in "${vsftp_conf[@]}"; do
        if [ -f "$conf" ]; then
            grep -Ei "^userlist_enable=YES" "$conf" | grep -v '^#' >/dev/null
            if [ $? -eq 0 ]; then
                root_blocked=true
                현황+=("vsftpd userlist_enable 활성")
            fi
        fi
    done

    #############################################
    # 결과
    #############################################
    if $root_blocked; then
        diagnosisResult="양호"
        status=$(IFS=' | '; echo "${현황[*]}")
    else
        diagnosisResult="취약"
        if [ ${#현황[@]} -eq 0 ]; then
            status="root FTP 접속 제한 설정 없음"
        else
            status=$(IFS=' | '; echo "${현황[*]}")
        fi
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
