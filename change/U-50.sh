#!/bin/bash

# 불필요한 계정 목록 정의
unnecessary_accounts=(
  "bin" "sys" "adm" "listen" "nobody4" "noaccess" "diag"
  "operator" "gopher" "games" "ftp" "apache" "httpd" "www-data"
  "mysql" "mariadb" "postgres" "mail" "postfix" "news" "lp"
  "uucp" "nuucp" "sync" "shutdown" "halt" "mailnull" "smmsp"
  "manager" "dumper" "abuse" "webmaster" "noc" "security"
  "hostmaster" "info" "marketing" "sales" "support" "accounts"
  "help" "admin" "guest" "user" "ubuntu"
)

# 관리자 그룹(root)에서 불필요한 계정 제거 함수
remove_unnecessary_accounts_from_root_group() {
    for account in "${unnecessary_accounts[@]}"; do
        if grep -q "^root:.*$account" /etc/group; then
            echo "관리자 그룹(root)에서 불필요한 계정 '$account'을(를) 제거합니다."
            gpasswd -d "$account" root
        else
            echo "관리자 그룹(root)에 계정 '$account'은(는) 존재하지 않습니다."
        fi
    done
}

main() {
    echo "관리자 그룹(root)에서 불필요한 계정 제거 시작..."
    remove_unnecessary_accounts_from_root_group
    echo "U-50 관리자 그룹(root)에서 불필요한 계정 제거 완료."
}

main
