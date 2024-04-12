#!/bin/bash

# 홈 디렉터리의 소유자를 확인하고 적절한 권한을 설정하는 스크립트

# 사용자의 홈 디렉터리 소유자와 권한을 조정합니다.
adjust_home_directories() {
    # /etc/passwd 파일에서 UID 1000 이상의 모든 사용자를 대상으로 합니다.
    awk -F: '$3 >= 1000 {print $1, $6}' /etc/passwd | while read user home_dir; do
        if [ -d "$home_dir" ]; then
            # 홈 디렉터리의 소유자를 확인하고 필요한 경우 조정합니다.
            current_owner=$(stat -c "%U" "$home_dir")
            if [ "$current_owner" != "$user" ]; then
                echo "조치: $home_dir 디렉터리의 소유자를 $user 로 변경합니다."
                chown "$user":"$user" "$home_dir"
            else
                echo "양호: $home_dir 디렉터리의 소유자가 이미 $user 입니다."
            fi

            # 홈 디렉터리의 권한을 확인하고 필요한 경우 조정합니다.
            permissions=$(stat -c "%A" "$home_dir")
            if [[ "$permissions" = *w* ]]; then
                echo "U-57 조치: $home_dir 디렉터리에서 타 사용자의 쓰기 권한을 제거합니다."
                chmod o-w "$home_dir"
            else
                echo "U-57 양호: $home_dir 디렉터리에 타 사용자의 쓰기 권한이 설정되어 있지 않습니다."
            fi
        else
            echo "U-57 경고: $home_dir 디렉터리가 존재하지 않습니다."
        fi
    done
}

main() {
    adjust_home_directories
}

main
