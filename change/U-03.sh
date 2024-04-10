#!/bin/bash

# 계정 잠금 임계값 설정
threshold=10
files_to_update=(
    "/etc/pam.d/system-auth"
    "/etc/pam.d/password-auth"
)

update_pam_configuration() {
    local file_path="$1"
    local threshold="$2"
    local preauth="auth required pam_faillock.so preauth silent deny=$threshold unlock_time=600"
    local authfail="auth [default=die] pam_faillock.so authfail deny=$threshold unlock_time=600"
    local account="account required pam_faillock.so"

    # Check if pam_faillock is already configured
    if grep -q "pam_faillock.so" "$file_path"; then
        sed -i "/pam_faillock.so/c\\$preauth\n$authfail" "$file_path"
    else
        # Insert pam_faillock configuration at the beginning of the file
        sed -i "1s;^;$preauth\n$authfail\n;" "$file_path"
        echo "$account" >> "$file_path"
    fi

    echo "Updated $file_path with account lockout threshold of $threshold attempts."
}

for file_path in "${files_to_update[@]}"; do
    if [ -f "$file_path" ]; then
        update_pam_configuration "$file_path" "$threshold"
    else
        echo "$file_path does not exist."
    fi
done

echo "계정 잠금 임계값이 $threshold 회로 설정되었습니다."