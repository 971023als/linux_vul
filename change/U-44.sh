#!/bin/bash

# /etc/passwd 파일에서 UID가 '0'이고 사용자 이름이 'root'가 아닌 계정 검사
vulnerable_accounts=()
while IFS=: read -r username _ userid _; do
    if [ "$userid" == "0" ] && [ "$username" != "root" ]; then
        vulnerable_accounts+=("$username")
    fi
done < /etc/passwd

# 결과 출력
cat $results_file
