#!/bin/bash

min_regular_user_uid=1000
declare -A uid_counts
duplicate_uids=()

if [ -f "/etc/passwd" ]; then
    # UID를 추출하고, 정규 사용자 UID(>=1000)에 대해 중복을 검사합니다.
    while IFS=: read -r username _ uid _; do
        if [ "$uid" -ge "$min_regular_user_uid" ]; then
            uid_counts["$uid"]=$((uid_counts["$uid"]+1))
        fi
    done < <(grep -v '^#' /etc/passwd)

    for uid in "${!uid_counts[@]}"; do
        if [ "${uid_counts[$uid]}" -gt 1 ]; then
            duplicate_uids+=("UID $uid (${uid_counts[$uid]}x)")
        fi
    done

    if [ ${#duplicate_uids[@]} -gt 0 ]; then
        duplicates_formatted=$(IFS=, ; echo "${duplicate_uids[*]}")
        jq --arg duplicates "$duplicates_formatted" '.진단 결과 = "취약" | .현황 += ["동일한 UID로 설정된 사용자 계정이 존재합니다: " + $duplicates]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    else
        jq '.현황 += ["동일한 UID를 공유하는 사용자 계정이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
else
    jq '.진단 결과 = "취약" | .현황 += ["/etc/passwd 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
