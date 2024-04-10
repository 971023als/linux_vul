#!/bin/bash

r_commands=("rsh" "rlogin" "rexec" "shell" "login" "exec")
xinetd_dir="/etc/xinetd.d"
inetd_conf="/etc/inetd.conf"

# xinetd.d 아래 서비스 비활성화
if [ -d "$xinetd_dir" ]; then
    for r_command in "${r_commands[@]}"; do
        service_path="$xinetd_dir/$r_command"
        if [ -f "$service_path" ]; then
            sed -i 's/disable\s*=\s*no/disable = yes/' "$service_path"
            echo "$r_command 서비스가 $service_path 파일에서 비활성화되었습니다."
        fi
    done
fi

# inetd.conf에서 r 계열 서비스 비활성화
if [ -f "$inetd_conf" ]; then
    for r_command in "${r_commands[@]}"; do
        sed -i "/^$r_command/s/^/#/" "$inetd_conf"
        echo "$r_command 서비스가 $inetd_conf 파일에서 비활성화되었습니다."
    done
fi

echo "모든 r 계열 서비스가 비활성화되었습니다."
