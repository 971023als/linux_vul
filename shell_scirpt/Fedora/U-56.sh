#!/bin/bash

# Initialize results JSON
results_file="results.json"
echo '{
    "분류": "파일 및 디렉토리 관리",
    "코드": "U-56",
    "위험도": "중",
    "진단 항목": "UMASK 설정 관리",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "UMASK 값이 022 이상으로 설정"
}' > $results_file

# Define files to check
files_to_check=(
    "/etc/profile"
    "/etc/bash.bashrc"
    "/etc/csh.login"
    "/etc/csh.cshrc"
    $(glob /home/*/.profile)
    $(glob /home/*/.bashrc)
    $(glob /home/*/.cshrc)
    $(glob /home/*/.login)
)

checked_files=0

# Check umask values in each file
for file_path in "${files_to_check[@]}"; do
    if [ -f "$file_path" ]; then
        checked_files=$((checked_files + 1))
        if grep -q "umask" "$file_path" && ! grep -E "^#" "$file_path" | grep -q "umask"; then
            umask_values=$(grep "umask" "$file_path" | awk '{print $2}' | tr -d '`')
            for value in $umask_values; do
                if [ $(("$value")) -lt 022 ]; then
                    jq --arg file_path "$file_path" --arg value "$value" '.진단 결과 = "취약" | .현황 += [$file_path + " 파일에서 UMASK 값 (" + $value + ")이 022 이상으로 설정되지 않았습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
                fi
            done
        fi
    fi
done

if [ "$checked_files" -eq 0 ]; then
    jq '.현황 += ["검사할 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
elif [ $(jq '.진단 결과' $results_file) == "\"양호\"" ]; then
    jq '.현황 += ["모든 검사된 파일에서 UMASK 값이 022 이상으로 적절히 설정되었습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# Display the results
cat $results_file
