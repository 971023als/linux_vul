#!/bin/bash


if [ -f "/etc/group" ] && [ -f "/etc/passwd" ]; then
    # /etc/passwd에서 사용 중인 GID 추출
    gids_in_use=$(cut -d: -f4 /etc/passwd | sort -u)

    unnecessary_groups=()
    while IFS=: read -r group_name _ gid members; do
        # GID가 500 이상이고 사용 중이지 않으며, 그룹 멤버가 없는 경우 확인
        if [ "$gid" -ge 500 ] && [[ ! " $gids_in_use " =~ " $gid " ]] && [ -z "$members" ]; then
            unnecessary_groups+=("$group_name")
        fi
    done < "/etc/group"

    if [ ${#unnecessary_groups[@]} -gt 0 ]; then
        jq --arg groups "$(IFS=, ; echo "${unnecessary_groups[*]}")" '.진단 결과 = "취약" | .현황 += ["계정이 없는 불필요한 그룹이 존재합니다: " + $groups]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    else
        jq '.현황 += ["계정이 없는 불필요한 그룹이 존재하지 않습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
else
    jq '.진단 결과 = "취약" | .현황 += ["/etc/group 또는 /etc/passwd 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
