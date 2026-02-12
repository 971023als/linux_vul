#!/bin/bash

OUTPUT_CSV="output.csv"

# CSV 헤더 생성
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,diagnosisResult,status" > $OUTPUT_CSV
fi

# 초기값
category="서비스 관리"
code="U-56"
riskLevel="하"
diagnosisItem="FTP 서비스 접근 제어 설정"
diagnosisResult=""
status=""

echo "$category,$code,$riskLevel,$diagnosisItem,$diagnosisResult,$status" >> $OUTPUT_CSV

#############################################
# 변수
#############################################
ftp_running=false
access_control_ok=false
현황=()

#############################################
# 1. FTP 서비스 실행 여부 확인
#############################################
if ps -ef | egrep "vsftpd|proftpd|pure-ftpd" | grep -v grep >/dev/null; then
    ftp_running=true
fi

# 21포트 LISTEN 확인
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
    # 3. ftpusers 접근 제한 파일
    #############################################
    ftpusers_files=(
        "/etc/ftpusers"
        "/etc/vsftpd/ftpusers"
        "/etc/vsftpd/user_list"
    )

    for f in "${ftpusers_files[@]}"; do
        if [ -f "$f" ]; then
            owner=$(stat -c %U "$f" 2>/dev/null)
            perm=$(stat -c %a "$f" 2>/dev/null)

            if [[ "$owner" == "root" && "$perm" -le 640 ]]; then
                access_control_ok=true
                현황+=("$f 접근제어 설정 정상")
            else
                현황+=("$f 권한 또는 소유자 취약 (owner:$owner perm:$perm)")
            fi
        fi
    done

    #############################################
    # 4. vsftpd allow/deny 설정 확인
    #############################################
    vsftp_conf=(
        "/etc/vsftpd.conf"
        "/etc/vsftpd/vsftpd.conf"
    )

    for file in "${vsftp_conf[@]}"; do
        if [ -f "$file" ]; then
            grep -Ei "tcp_wrappers=YES|userlist_enable=YES" "$file" | grep -v '^#' >/dev/null
            if [ $? -eq 0 ]; then
                access_control_ok=true
                현황+=("vsftpd 접근제어 설정 확인")
            fi
        fi
    done

    #############################################
    # 5. TCP Wrapper 확인
    #############################################
    if [ -f /etc/hosts.deny ] && [ -f /etc/hosts.allow ]; then
        grep -i ftp /etc/hosts.deny >/dev/null
        if [ $? -eq 0 ]; then
            access_control_ok=true
            현황+=("TCP Wrapper FTP 접근제어 설정")
        fi
    fi

    #############################################
    # 결과 판단
    #############################################
    if $access_control_ok; then
        diagnosisResult="양호"
        status=$(IFS=' | '; echo "${현황[*]}")
    else
        diagnosisResult="취약"
        if [ ${#현황[@]} -eq 0 ]; then
            status="FTP 접근제어 설정 미흡"
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
