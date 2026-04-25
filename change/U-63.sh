#!/bin/bash

# FTP 접근제어 파일(ftpusers) 소유자 및 권한 설정 스크립트

# FTP 접근제어 파일 목록
ftpusers_files=(
    "/etc/ftpusers" "/etc/pure-ftpd/ftpusers" "/etc/wu-ftpd/ftpusers"
    "/etc/vsftpd/ftpusers" "/etc/proftpd/ftpusers" "/etc/ftpd/ftpusers"
    "/etc/vsftpd.ftpusers" "/etc/vsftpd.user_list" "/etc/vsftpd/user_list"
)

secure_ftpusers_files() {
    echo "FTP 접근제어 파일의 소유자 및 권한 조정 중..."

    for ftpusers_file in "${ftpusers_files[@]}"; do
        if [ -f "$ftpusers_file" ]; then
            echo "파일 처리 중: $ftpusers_file"

            # 소유자를 root로 변경
            chown root:root "$ftpusers_file"
            
            # 권한을 640 이하로 설정
            chmod 640 "$ftpusers_file"
            
            echo "U-63 $ftpusers_file 파일의 소유자를 root로 설정하고, 권한을 640으로 설정했습니다."
        else
            echo "U-63 $ftpusers_file 파일이 존재하지 않습니다."
        fi
    done
}

main() {
    secure_ftpusers_files
}

main

# ==== 조치 결과 MD 출력 ====
_change_code="U-63"
_change_item="FTP 접근제어 파일의 소유자 및 권한 조정 중..."
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
