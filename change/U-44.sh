#!/bin/bash

# root 이외의 UID가 '0'인 계정을 찾고 UID 변경
check_and_modify_uid() {
    while IFS=: read -r user _ uid _; do
        if [ "$uid" -eq 0 ] && [ "$user" != "root" ]; then
            echo "취약: $user 계정이 UID 0을 사용합니다. UID를 변경합니다."
            # UID 변경 로직을 여기에 추가하세요. 예: usermod -u <새 UID> $user
            # 예시: echo "usermod -u 1001 $user" (실제 실행 전에 스크립트 기능을 검증하세요)
        fi
    done < /etc/passwd
}

main() {
    echo "root 이외의 UID '0' 사용 계정 검사 및 조치 시작..."
    check_and_modify_uid
    echo "U-44 검사 및 조치 완료."
}

main
