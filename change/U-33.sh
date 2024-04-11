#!/bin/bash

# 최소 요구 BIND 버전
minimum_version="9.18.7"

# 버전 비교 함수
version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

# 시스템 패키지 관리자를 통해 설치된 BIND 버전 확인
if command -v rpm &> /dev/null; then
    installed_version=$(rpm -q --qf "%{VERSION}\n" bind | sort -V | tail -n 1)
elif command -v dpkg &> /dev/null; then
    installed_version=$(dpkg -l | grep -oP 'bind9\s+\K[\d.]+')
else
    echo "지원되지 않는 패키지 관리자입니다. rpm 또는 dpkg를 사용해주세요."
    exit 1
fi

# 버전 확인 및 업데이트 권장
if [ -z "$installed_version" ]; then
    echo "BIND가 설치되어 있지 않습니다."
elif version_gt "$minimum_version" "$installed_version"; then
    echo "현재 BIND 버전($installed_version)은 최신 보안 패치 버전($minimum_version) 이하입니다. 업데이트를 권장합니다."
    # 업데이트 명령 예시 (실제 사용 전에 적절한 패키지 관리자 명령으로 수정 필요)
    # yum update bind
    # 또는
    # apt-get install bind9
else
    echo "U-33 현재 BIND 버전($installed_version)은 최신 보안 패치 버전($minimum_version) 이상입니다."
fi
