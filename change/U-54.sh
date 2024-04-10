#!/bin/bash

# Files and patterns to check for session timeout settings
check_files=("/etc/profile" "/etc/csh.login" "/etc/csh.cshrc")
check_patterns="/home/*/.profile"

file_exists_count=0
no_tmout_setting_file=0

# Check specific files
for file_path in ${check_files[@]}; do
    if [ -f "$file_path" ]; then
        ((file_exists_count++))
        if ! grep -Eq "TMOUT|autologout" "$file_path"; then
            ((no_tmout_setting_file++))
        fi
    fi
done

# Check files matching patterns
for file_path in $check_patterns; do
    if [ -f "$file_path" ]; then
        ((file_exists_count++))
        if ! grep -Eq "TMOUT|autologout" "$file_path"; then
            ((no_tmout_setting_file++))
        fi
    fi
done

# Final assessment
if [ $file_exists_count -eq 0 ]; then
    jq '.진단 결과 = "취약" | .현황 += ["세션 타임아웃을 설정하는 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
elif [ $file_exists_count -eq $no_tmout_setting_file ]; then
    jq '.진단 결과 = "취약" | .현황 += ["세션 타임아웃을 설정한 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
else
    jq '.현황 += ["세션 타임아웃 설정이 적절히 구성되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# Print the results
cat $results_file
