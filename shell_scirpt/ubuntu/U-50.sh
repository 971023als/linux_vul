#!/bin/bash

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="계정관리"
code="U-50"
riskLevel="하"
diagnosisItem="관리자 그룹에 최소한의 계정 포함"
service="Account Management"
diagnosisResult="양호"
status=""

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

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
                for unnecessary_account in "${unnecessary_accounts[@]}"; do
                    if [ "$account" == "$unnecessary_account" ]; then
                        found_accounts+=("$account")
                        break
                    fi
                done
            done

            if [ ${#found_accounts[@]} -gt 0 ]; then
                diagnosisResult="관리자 그룹(root)에 불필요한 계정이 등록되어 있습니다: ${found_accounts[*]}"
                status="취약"
                echo "WARN: $diagnosisResult"
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            else
                diagnosisResult="관리자 그룹(root)에 불필요한 계정이 없습니다."
                status="양호"
                echo "OK: $diagnosisResult"
                echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
            fi
            break
        fi
    done < "/etc/group"

    if [ "$root_group_found" = false ]; then
        diagnosisResult="관리자 그룹(root)을 /etc/group 파일에서 찾을 수 없습니다."
        status="오류"
        echo "ERROR: $diagnosisResult"
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    fi
else
    diagnosisResult="/etc/group 파일이 없습니다."
    status="취약"
    echo "WARN: $diagnosisResult"
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
fi

# Output CSV
cat $OUTPUT_CSV
