#!/bin/bash

# 불필요한 계정 목록 정의
unnecessary_accounts=(
  "user"
  "test"
  "guest"
  "info"
  "adm"
  "mysql"
  "user1"
)

# 불필요한 계정 제거 함수
remove_unnecessary_accounts() {
    for account in "${unnecessary_accounts[@]}"; do
        if id "$account" &>/dev/null; then
            echo "불필요한 계정 '$account'을(를) 제거합니다."
            userdel -r "$account"
        else
            echo "계정 '$account'은(는) 존재하지 않습니다."
        fi
    done
}

main() {
    echo "불필요한 계정 제거 시작..."
    remove_unnecessary_accounts
    echo "불필요한 계정 제거 완료."
}

main
