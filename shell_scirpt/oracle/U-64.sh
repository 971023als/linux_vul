#!/bin/bash

# 초기 진단 결과 및 현황 설정
category="서비스 관리"
code="U-64"
severity="중"
check_item="ftpusers 파일 설정(FTP 서비스 root 계정 접근제한)"
result=""
declare -a status
recommendation="FTP 서비스가 활성화된 경우 root 계정 접속을 차단"

# 검사할 ftpusers 파일 및 설정 파일 목록
ftpusers_files=(
    "/etc/ftpusers" "/etc/ftpd/ftpusers" "/etc/proftpd.conf"
    "/etc/vsftp/ftpusers" "/etc/vsftp/user_list" "/etc/vsftpd.ftpusers"
    "/etc/vsftpd.user_list"
)

# 실행 중인 FTP 서비스 확인
if ! pgrep -f -e ftpd && ! pgrep -f -e vsftpd && ! pgrep -f -e proftpd; then
    status+=("FTP 서비스가 비활성화 되어 있습니다.")
    result="양호"
else
    root_access_restricted=false

    for ftpusers_file in "${ftpusers_files[@]}"; do
        if [ -f "$ftpusers_file" ]; then
            # proftpd.conf의 경우 'RootLogin on' 설정 확인
            if [[ "$ftpusers_file" == *proftpd.conf* ]] && grep -q "RootLogin on" "$ftpusers_file"; then
                result="취약"
                status+=("$ftpusers_file 파일에 'RootLogin on' 설정이 있습니다.")
                break
            # 다른 ftpusers 파일의 경우 'root' 존재 확인
            elif grep -q "^root$" "$ftpusers_file"; then
                root_access_restricted=true
            fi
        fi
    done

    if $root_access_restricted; then
        result="양호"
        status+=("FTP 서비스 root 계정 접근이 제한되어 있습니다.")
    else
        result="취약"
        status+=("FTP 서비스 root 계정 접근 제한 설정이 충분하지 않습니다.")
    fi
fi

# 결과 출력
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황:"
for i in "${status[@]}"; do
    echo "- $i"
done
echo "대응방안: $recommendation"
