#!/bin/bash

# Initialize the results file
results_file="results.json"
echo '{
    "분류": "파일 및 디렉토리 관리",
    "코드": "U-57",
    "위험도": "중",
    "진단 항목": "홈디렉토리 소유자 및 권한 설정",
    "진단 결과": "양호",
    "현황": [],
    "대응방안": "홈 디렉터리 소유자를 해당 계정으로 설정 및 타 사용자 쓰기 권한 제거"
}' > $results_file

# Get all user entries and iterate
getent passwd | while IFS=: read -r username _ uid _ _ homedir _; do
    # Skip system users by UID
    if [ "$uid" -ge 1000 ]; then
        if [ -d "$homedir" ]; then
            dir_owner_uid=$(stat -c "%u" "$homedir")
            if [ "$dir_owner_uid" != "$uid" ]; then
                echo "{\"현황\": \"${homedir} 홈 디렉터리의 소유자가 ${username}이(가) 아닙니다.\"}" >> $results_file
                echo "{\"진단 결과\": \"취약\"}" >> $results_file
            fi
            if [ "$(stat -c "%A" "$homedir" | cut -c8)" == "w" ]; then
                echo "{\"현황\": \"${homedir} 홈 디렉터리에 타 사용자(other) 쓰기 권한이 설정되어 있습니다.\"}" >> $results_file
                echo "{\"진단 결과\": \"취약\"}" >> $results_file
            fi
        else
            echo "{\"현황\": \"${homedir} 홈 디렉터리가 존재하지 않습니다.\"}" >> $results_file
            echo "{\"진단 결과\": \"취약\"}" >> $results_file
        fi
    fi
done

# Note: This script appends results directly to the JSON file, which isn't valid JSON format.
# It's a demonstration of how to translate the logic from Python to Bash.
# You might need to use a tool like 'jq' to properly format the JSON output.

# Display the results
cat $results_file
