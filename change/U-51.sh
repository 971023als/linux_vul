#!/bin/bash

# 불필요한 그룹을 찾고 제거하는 함수
remove_unnecessary_groups() {
    if [[ ! -f "/etc/group" || ! -f "/etc/passwd" ]]; then
        echo "/etc/group 또는 /etc/passwd 파일이 없습니다."
        return
    fi

    # /etc/passwd에서 사용 중인 GID 추출
    gids_in_use=$(cut -d: -f4 /etc/passwd | sort -u)

    # GID >= 500인 그룹 찾기
    grep -E ":[0-9]{3,}:" /etc/group | while read -r group_line; do
        gid=$(echo "$group_line" | cut -d: -f3)
        group_name=$(echo "$group_line" | cut -d: -f1)
        members=$(echo "$group_line" | cut -d: -f4)

        # GID가 사용 중인지 및 멤버가 있는지 확인
        if [[ ! " $gids_in_use " =~ " $gid " ]] && [[ -z "$members" ]]; then
            echo "불필요한 그룹 '$group_name'을(를) 제거합니다."
            groupdel "$group_name"
        fi
    done
}

main() {
    echo "계정이 없는 불필요한 그룹 제거 시작..."
    remove_unnecessary_groups
    echo "U-51 계정이 없는 불필요한 그룹 제거 완료."
}

main

# ==== 조치 결과 MD 출력 ====
_change_code="U-51"
_change_item="/etc/group 또는 /etc/passwd 파일이 "
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
