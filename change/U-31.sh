#!/bin/bash

search_directory='/etc/mail/'
relay_restrictions='R$\* $: $(check_relay $)'

# sendmail.cf 파일 검색 및 릴레이 제한 설정
find "$search_directory" -name 'sendmail.cf' -type f | while read -r file_path; do
    if [ -f "$file_path" ]; then
        # 릴레이 제한 설정이 이미 존재하는지 확인
        if grep -qE 'R\$\*' "$file_path" || grep -qEi 'Relaying denied' "$file_path"; then
            echo "$file_path 파일에 릴레이 제한이 이미 적절히 설정되어 있습니다."
        else
            # 릴레이 제한 설정 추가
            echo "$relay_restrictions" >> "$file_path"
            echo "$file_path 파일에 릴레이 제한 설정을 추가했습니다."
        fi
    else
        echo "sendmail.cf 파일을 찾을 수 없습니다."
    fi
done

echo "스팸 메일 릴레이 제한 설정이 완료되었습니다."
