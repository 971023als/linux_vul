#!/bin/bash

# 결과를 저장할 JSON 파일 초기화
results_file="results.json"
echo '{
    "분류": "계정관리",
    "코드": "U-53",
    "위험도": "하",
    "진단 항목": "사용자 shell 점검",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "로그인이 필요하지 않은 계정에 /bin/false 또는 /sbin/nologin 쉘 부여"
}' > $results_file

# 불필요한 계정 목록
unnecessary_accounts=(
    "daemon" "bin" "sys" "adm" "listen" "nobody" "nobody4"
    "noaccess" "diag" "operator" "gopher" "games" "ftp" "apache"
    "httpd" "www-data" "mysql" "mariadb" "postgres" "mail" "postfix"
    "news" "lp" "uucp" "nuucp"
)

if [ -f "/etc/passwd" ]; then
    while IFS=: read -r username _ _ _ _ _ shell; do
        for account in "${unnecessary_accounts[@]}"; do
            if [ "$username" == "$account" ] && [ "$shell" != "/bin/false" ] && [ "$shell" != "/sbin/nologin" ]; then
                jq --arg username "$username" '.진단 결과 = "취약" | .현황 += ["계정 " + $username + "에 /bin/false 또는 /sbin/nologin 쉘이 부여되지 않았습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
                break 2
            fi
        done
    done < /etc/passwd
else
    jq '.진단 결과 = "취약" | .현황 += ["/etc/passwd 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
