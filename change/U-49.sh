#!/bin/bash

# 로그인이 가능한 쉘 목록
login_shells=("/bin/bash" "/bin/sh")
# 검사할 불필요한 계정 목록
unnecessary_accounts=("user" "test" "guest" "info" "adm" "mysql" "user1")

# 불필요한 계정 찾기
found_accounts=()
for account in "${unnecessary_accounts[@]}"; do
    if getent passwd "$account" > /dev/null; then
        shell=$(getent passwd "$account" | cut -d: -f7)
        for login_shell in "${login_shells[@]}"; do
            if [[ "$shell" == "$login_shell" ]]; then
                found_accounts+=("$account")
                break
            fi
        done
    fi
done

if [ ${#found_accounts[@]} -gt 0 ]; then
    jq --arg accounts "$(IFS=, ; echo "${found_accounts[*]}")" '.진단 결과 = "취약" | .현황 += ["불필요한 계정이 존재합니다: " + $accounts]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
else
    # 양호한 경우, 현황에 양호 메시지 추가
    jq '.현황 += ["불필요한 계정이 존재하지 않습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
