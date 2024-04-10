#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "계정관리",
    "코드": "U-51",
    "위험도": "하",
    "진단 항목": "계정이 존재하지 않는 GID 금지",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "계정이 없는 불필요한 그룹 삭제"
}' > $results_file

if [ -f "/etc/group" ] && [ -f "/etc/passwd" ]; then
    # Extract GIDs in use from /etc/passwd
    gids_in_use=$(cut -d: -f4 /etc/passwd | sort -u)

    unnecessary_groups=()
    while IFS=: read -r group_name _ gid members; do
        # Check if GID is >= 500 and not in use or group is empty
        if [ "$gid" -ge 500 ] && [[ ! " $gids_in_use " =~ " $gid " ]] && [ -z "$members" ]; then
            unnecessary_groups+=("$group_name")
        fi
    done < "/etc/group"

    if [ ${#unnecessary_groups[@]} -gt 0 ]; then
        jq --arg groups "$(IFS=, ; echo "${unnecessary_groups[*]}")" '.진단 결과 = "취약" | .현황 += ["계정이 없는 불필요한 그룹이 존재합니다: " + $groups]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
else
    jq '.진단 결과 = "취약" | .현황 += ["/etc/group 또는 /etc/passwd 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
