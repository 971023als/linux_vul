#!/bin/bash

# 중복 UID가 있는 사용자 계정 식별 및 보고
identify_duplicate_uids() {
    echo "중복 UID를 가진 계정 식별 중..."
    awk -F: 'BEGIN { min_uid=1000 } $3 >= min_uid { print $3 }' /etc/passwd | sort | uniq -d | while read -r uid; do
        echo "중복 UID 발견: $uid"
        grep ":$uid:" /etc/passwd | awk -F: '{ print "계정명: " $1 ", UID: " $3 }'
    done
}

# 중복 UID 계정의 조치를 위한 권장 사항 출력
recommendations_for_duplicate_uids() {
    echo "U-52 조치 권장 사항:"
    echo "- 각 사용자 계정이 고유한 UID를 갖도록 중복 UID를 가진 계정을 제거하거나 수정합니다."
    echo "- 필요한 경우 시스템 관리자와 협력하여 계정을 재구성하세요."
}

main() {
    identify_duplicate_uids
    recommendations_for_duplicate_uids
}

main
