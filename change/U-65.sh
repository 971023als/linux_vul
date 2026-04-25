#!/bin/bash

# at 서비스 권한 설정 스크립트

# at 관련 파일 및 디렉토리 설정
AT_COMMAND_PATHS=$(which at 2>/dev/null)
AT_ACCESS_CONTROL_FILES=("/etc/at.allow" "/etc/at.deny")

# at 명령어 실행 파일 권한 설정
for at_path in $AT_COMMAND_PATHS; do
    if [ -f "$at_path" ]; then
        # 실행 가능한 권한 제거 (other 사용자)
        chmod o-x "$at_path"
        echo "$at_path 실행 파일에 대한 'other' 사용자의 실행 권한을 제거했습니다."
    fi
done

# /etc/at.allow 및 /etc/at.deny 파일 권한 설정
for file in "${AT_ACCESS_CONTROL_FILES[@]}"; do
    if [ -f "$file" ]; then
        # 소유자를 root로 변경
        chown root:root "$file"
        # 권한을 640으로 설정
        chmod 640 "$file"
        echo "$file 파일의 소유자를 root로 설정하고 권한을 640으로 변경했습니다."
    else
        echo "$file 파일이 존재하지 않습니다."
    fi
done

echo "U-65 at 서비스 관련 파일의 권한 설정이 완료되었습니다."

# ==== 조치 결과 MD 출력 ====
_change_code="U-65"
_change_item="$at_path 실행 파일에 대한 'other' 사용자"
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
