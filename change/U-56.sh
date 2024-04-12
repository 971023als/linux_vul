#!/bin/bash

# UMASK 값을 022 이상으로 설정하는 스크립트

configure_umask() {
    local files_to_check=(
        "/etc/profile"
        "/etc/bash.bashrc"
        "/etc/csh.login"
        "/etc/csh.cshrc"
        "/home/*/.profile"
        "/home/*/.bashrc"
        "/home/*/.cshrc"
        "/home/*/.login"
    )

    for file_path in "${files_to_check[@]}"; do
        if [[ -f "$file_path" ]]; then
            echo "검사 중: $file_path"
            # umask 값이 설정되어 있는지 확인하고, 필요하다면 수정합니다.
            if grep -q "umask" "$file_path" && ! grep -qE "umask[[:space:]]+0[2-7][2-7]" "$file_path"; then
                echo "U-56 조치: $file_path 파일의 umask 값을 022로 설정합니다."
                sed -i '/umask/c\umask 022' "$file_path"
            else
                echo "U-56 양호: $file_path 파일의 umask 값이 이미 적절하게 설정되어 있습니다."
            fi
        else
            echo "U-56 경고: $file_path 파일이 존재하지 않습니다."
        fi
    done
}

main() {
    configure_umask
}

main
