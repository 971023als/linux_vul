#!/bin/bash

# sendmail.cf 파일들 찾기 및 restrictqrun 옵션 설정
find / -name 'sendmail.cf' -type f 2>/dev/null | while read -r file_path; do
    # restrictqrun 옵션이 이미 설정되어 있는지 확인
    if grep -q 'restrictqrun' "$file_path"; then
        echo "$file_path 파일에 restrictqrun 옵션이 이미 설정되어 있습니다."
    else
        # restrictqrun 옵션 추가
        echo "O QueueLA=12" >> "$file_path"  # 예시: QueueLA 값을 사용하여 옵션 추가
        echo "O QueueSortOrder=host" >> "$file_path"  # 추가적인 예시 설정
        echo "O restrictqrun" >> "$file_path"
        echo "$file_path 파일에 restrictqrun 옵션이 추가되었습니다."
    fi
done

echo "일반 사용자의 Sendmail 실행 방지 설정이 완료되었습니다."
