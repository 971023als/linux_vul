#!/bin/bash

# 검사할 실행 파일 목록
executables=(
    "/sbin/dump" "/sbin/restore" "/sbin/unix_chkpwd"
    "/usr/bin/at" "/usr/bin/lpq" "/usr/bin/lpq-lpd"
    "/usr/bin/lpr" "/usr/bin/lpr-lpd" "/usr/bin/lprm"
    "/usr/bin/lprm-lpd" "/usr/bin/newgrp" "/usr/sbin/lpc"
    "/usr/sbin/lpc-lpd" "/usr/sbin/traceroute"
)

# SUID와 SGID 설정 제거
for executable in "${executables[@]}"; do
    if [ -f "$executable" ]; then
        # SUID와 SGID 비트 제거
        chmod -s "$executable"
        echo "제거됨: SUID와 SGID 설정이 $executable 파일에서 제거되었습니다."
    else
        echo "파일 없음: $executable 파일이 존재하지 않습니다."
    fi
done

echo "모든 지정된 실행 파일에서 SUID와 SGID 설정이 제거되었습니다."
