#!/bin/bash

# 홈 디렉터리의 존재를 검사하고, 필요한 경우 생성하는 스크립트

# 사용자 계정의 홈 디렉터리를 검사하고 생성합니다.
check_and_create_home_directories() {
    # UID가 1000 이상인 모든 사용자 계정에 대해 실행
    awk -F: '$3 >= 1000 {print $1, $6}' /etc/passwd | while read user home_dir; do
        if [ ! -d "$home_dir" ]; then
            # 홈 디렉터리가 존재하지 않는 경우
            echo "조치: $user 사용자의 홈 디렉터리($home_dir)를 생성합니다."
            mkdir -p "$home_dir"
            chown "$user:$user" "$home_dir"
            chmod 700 "$home_dir"
        elif [ "$home_dir" = "/" ] && [ "$user" != "root" ]; then
            # 홈 디렉터리가 루트('/')로 설정되었지만, 사용자가 root가 아닌 경우
            echo "U-58 경고: $user 사용자의 홈 디렉터리가 '/'로 설정되어 있습니다. 수동 조치가 필요합니다."
        else
            # 홈 디렉터리가 존재하며, 적절히 설정된 경우
            echo "U-58 양호: $user 사용자의 홈 디렉터리($home_dir)가 적절히 설정되어 있습니다."
        fi
    done
}

main() {
    check_and_create_home_directories
}

main
