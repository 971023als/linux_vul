#!/bin/bash

# 최신 Sendmail 버전 (이 예제에서는 8.17.1을 최신으로 가정합니다)
latest_version="8.17.1"

# 설치된 Sendmail 버전 확인
installed_version=$(rpm -q sendmail | grep -oP 'sendmail-\K[\d.]+')

if [ -z "$installed_version" ]; then
    echo "Sendmail이 설치되어 있지 않습니다."
else
    echo "설치된 Sendmail 버전: $installed_version"
    # 버전 비교
    if [ "$installed_version" != "$latest_version" ]; then
        echo "Sendmail 버전이 최신 버전이 아닙니다. 업그레이드를 진행합니다."
        # Sendmail 업그레이드 (RPM 기반 시스템을 위한 예제 명령어)
        yum update sendmail -y
        echo "Sendmail 업그레이드가 완료되었습니다."
    else
        echo "U-30 Sendmail 버전이 최신 버전($latest_version)입니다."
    fi
fi

# ==== 조치 결과 MD 출력 ====
_change_code="U-30"
_change_item="Sendmail이 설치되어 있지 않습니다."
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
