#!/bin/bash

# Initialize the results file
results_file="results.json"
echo '{
    "분류": "계정관리",
    "코드": "U-54",
    "위험도": "하",
    "진단 항목": "Session Timeout 설정",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "Session Timeout을 600초(10분) 이하로 설정"
}' > $results_file

# Files to check for session timeout settings
check_files=("/etc/profile" "/etc/csh.login" "/etc/csh.cshrc" "/home/*/.profile")

file_exists_count=0
no_tmout_setting_file=0

for file_path in ${check_files[@]}; do
    if [ -f "$file_path" ]; then
        file_exists_count=$((file_exists_count+1))
        if grep -q "TMOUT" "$file_path" || grep -q "autologout" "$file_path"; then
            while IFS= read -r line; do
                if echo "$line" | grep -q "TMOUT"; then
                    setting_value=$(echo "$line" | cut -d'=' -f2)
                    if [ "$setting_value" -gt 600 ]; then
                        jq --arg file_path "$file_path" '.진단 결과 = "취약" | .현황 += [$file_path + " 파일에 세션 타임아웃이 600초 이하로 설정되지 않았습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
                        break
                    fi
                elif echo "$line" | grep -q "autologout"; then
                    setting_value=$(echo "$line" | cut -d'=' -f2)
                    if [ "$setting_value" -gt 10 ]; then
                        jq --arg file_path "$file_path" '.진단 결과 = "취약" | .현황 += [$file_path + " 파일에 세션 타임아웃이 10분 이하로 설정되지 않았습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
                        break
                    fi
                fi
            done < "$file_path"
        else
            no_tmout_setting_file=$((no_tmout_setting_file+1))
        fi
    fi
done

if [ $file_exists_count -eq 0 ]; then
    jq '.진단 결과 = "취약" | .현황 += ["세션 타임아웃을 설정하는 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
elif [ $file_exists_count -eq $no_tmout_setting_file ]; then
    jq '.진단 결과 = "취약" | .현황 += ["세션 타임아웃을 설정한 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# Print the results
cat $results_file
