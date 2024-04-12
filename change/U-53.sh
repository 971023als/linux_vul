#!/bin/bash

# 로그인이 필요하지 않은 계정에 적절한 쉘 설정하기
set_proper_shell_for_unnecessary_accounts() {
    echo "로그인이 필요하지 않은 계정에 대한 쉘 설정 조치 시작..."

    # 로그인이 필요하지 않은 계정 목록
    unnecessary_accounts=(
        "daemon" "bin" "sys" "adm" "listen" "nobody" "nobody4"
        "noaccess" "diag" "operator" "gopher" "games" "ftp" "apache"
        "httpd" "www-data" "mysql" "mariadb" "postgres" "mail" "postfix"
        "news" "lp" "uucp" "nuucp"
    )

    # /etc/passwd 파일을 순회하면서 필요한 조치 실행
    while IFS=: read -r username _ _ _ _ _ shell; do
        if [[ " ${unnecessary_accounts[@]} " =~ " ${username} " ]] && [[ "$shell" != "/bin/false" && "$shell" != "/sbin/nologin" ]]; then
            echo "조치: $username 계정의 쉘을 /sbin/nologin으로 변경합니다."
            # 사용자 계정의 쉘을 /sbin/nologin으로 변경
            usermod -s /sbin/nologin "$username"
        fi
    done < /etc/passwd

    echo "U-53 모든 조치 완료."
}

main() {
    set_proper_shell_for_unnecessary_accounts
}

main
