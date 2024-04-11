#!/bin/bash

# 검사 대상 파일 목록
executables=(
    "/sbin/dump"
    "/sbin/restore"
    "/sbin/unix_chkpwd"
    "/usr/bin/at"
    "/usr/bin/lpq"
    "/usr/bin/lpq-lpd"
    "/usr/bin/lpr"
    "/usr/bin/lpr-lpd"
    "/usr/bin/lprm"
    "/usr/bin/lprm-lpd"
    "/usr/bin/newgrp"
    "/usr/sbin/lpc"
    "/usr/sbin/lpc-lpd"
    "/usr/sbin/traceroute"
)

# SUID 및 SGID 권한 제거
for executable in "${executables[@]}"; do
    if [ -f "$executable" ]; then
        # 현재 파일 권한 조회
        current_permissions=$(stat -c "%A" "$executable")
        echo "현재 $executable 권한: $current_permissions"
        
        # SUID 및 SGID 권한 제거
        chmod -s "$executable"
        
        # 변경 후 파일 권한 조회
        updated_permissions=$(stat -c "%A" "$executable")
        echo "U-13 변경 후 $executable 권한: $updated_permissions"
    else
        echo "U-13 $executable 파일이 존재하지 않습니다."
    fi
done
