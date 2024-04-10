#!/bin/bash


# 검사할 ftpusers 파일 목록
ftpusers_files=(
    "/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers"
    "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers"
    "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list"
)

for ftpusers_file in "${ftpusers_files[@]}"; do
    if [ -f "$ftpusers_file" ]; then
        file_checked_and_secure=true
        owner=$(stat -c "%U" "$ftpusers_file")
        permissions=$(stat -c "%a" "$ftpusers_file")

        # 소유자가 root가 아니거나 권한이 640보다 큰 경우, 수정
        if [ "$owner" != "root" ] || [ "$permissions" -gt 640 ]; then
            chown root "$ftpusers_file"
            chmod 640 "$ftpusers_file"
            status+=("$ftpusers_file 파일의 소유자와 권한을 적절히 수정하였습니다.")
        fi
    fi
done

# 파일 검사 후 취약하지 않은 경우 양호로 설정
if [ ${#status[@]} -eq 0 ]; then
    if $file_checked_and_secure; then
        result="양호"
        status=("모든 ftpusers 파일이 적절한 소유자 및 권한 설정을 가지고 있습니다.")
    else
        result="취약"
        status=("시스템에 ftp 접근제어 파일이 존재하지 않습니다.")
    fi
else
    result="조치 완료"
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
