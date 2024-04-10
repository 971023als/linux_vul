#!/bin/bash

# Define files to check
files_to_check=(
    "/etc/profile"
    "/etc/bash.bashrc"
    "/etc/csh.login"
    "/etc/csh.cshrc"
    /home/*/.profile
    /home/*/.bashrc
    /home/*/.cshrc
    /home/*/.login
)

checked_files=0

# Check umask values in each file
for file_path in "${files_to_check[@]}"; do
    if [ -f "$file_path" ]; then
        checked_files=$((checked_files + 1))
        while IFS= read -r line; do
            if echo "$line" | grep -q "umask" && ! echo "$line" | grep -E "^[[:space:]]*#" > /dev/null; then
                umask_value=$(echo "$line" | grep -o "umask [0-9]*" | awk '{print $2}')
                if [ "$umask_value" -lt 022 ]; then
                    jq --arg file_path "$file_path" --arg value "$umask_value" '.진단 결과 = "취약" | .현황 += [$file_path + " 파일에서 UMASK 값 (" + $value + ")이 022 이상으로 설정되지 않았습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
                    break
                fi
            fi
        done < "$file_path"
    fi
done

if [ "$checked_files" -eq 0 ]; then
    jq '.현황 += ["검사할 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
else
    if ! grep -q "취약" $results_file; then
        jq '.현황 += ["모든 검사된 파일에서 UMASK 값이 022 이상으로 적절히 설정되었습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
fi

# Display the results
cat $results_file
