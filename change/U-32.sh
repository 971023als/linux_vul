#!/bin/bash

# Sendmail의 설정 파일 경로를 찾음
sendmail_cf_files=$(find / -name 'sendmail.cf' -type f 2>/dev/null)

if [ -z "$sendmail_cf_files" ]; then
    echo "Sendmail 설정 파일(sendmail.cf)을 찾을 수 없습니다."
    exit 1
fi

# sendmail.cf 파일에 restrictqrun 옵션 설정
for file_path in $sendmail_cf_files; do
    if grep -q 'O RestrictQRun' "$file_path"; then
        echo "$file_path 파일에 이미 restrictqrun 옵션이 설정되어 있습니다."
    else
        echo "$file_path 파일에 restrictqrun 옵션을 추가합니다."
        echo "O RestrictQRun=True" >> "$file_path"
    fi
done

echo "U-32 일반 사용자의 Sendmail 실행 방지 설정이 완료되었습니다."
