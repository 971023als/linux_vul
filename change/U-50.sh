#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "계정관리",
    "코드": "U-50",
    "위험도": "하",
    "진단 항목": "관리자 그룹에 최소한의 계정 포함",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "관리자 그룹(root)에 불필요한 계정이 등록되지 않도록 관리"
}' > $results_file

# 불필요한 계정 목록
unnecessary_accounts=(
    "bin" "sys" "adm" "listen" "nobody4" "noaccess" "diag"
    "operator" "gopher" "games" "ftp" "apache" "httpd" "www-data"
    "mysql" "mariadb" "postgres" "mail" "postfix" "news" "lp"
    "uucp" "nuucp" "sync" "shutdown" "halt" "mailnull" "smmsp"
    "manager" "dumper" "abuse" "webmaster" "noc" "security"
    "hostmaster" "info" "marketing" "sales" "support" "accounts"
    "help" "admin" "guest" "user" "ubuntu"
)

if [ -f "/etc/group" ]; then
    root_group_found=false
    while IFS=: read -r group_name _ _ members; do
        if [ "$group_name" == "root" ]; then
            root_group_found=true
            IFS=',' read -ra members_array <<< "$members"
            found_accounts=()
            for account in "${members_array[@]}"; do
                if [[ " ${unnecessary_accounts[@]} " =~ " ${account} " ]]; then
                    found_accounts+=("$account")
                fi
            done

            if [ ${#found_accounts[@]} -gt 0 ]; then
                jq --arg accounts "$(IFS=, ; echo "${found_accounts[*]}")" '.진단 결과 = "취약" | .현황 += ["관리자 그룹(root)에 불필요한 계정이 등록되어 있습니다: " + $accounts]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
            else
                jq '.현황 += ["관리자 그룹(root)에 불필요한 계정이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
            fi
            break
        fi
    done < "/etc/group"

    if [ "$root_group_found" = false ]; then
        jq '.진단 결과 = "오류" | .현황 += ["관리자 그룹(root)을 /etc/group 파일에서 찾을 수 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
else
    jq '.진단 결과 = "취약" | .현황 += ["/etc/group 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
