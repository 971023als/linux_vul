#!/bin/bash

# autofs 서비스 상태 확인
if systemctl is-active --quiet autofs; then
    echo "autofs 서비스가 활성화되어 있습니다. 비활성화를 시도합니다."
    # autofs 서비스 비활성화 및 중지
    systemctl stop autofs
    systemctl disable autofs
    echo "autofs 서비스를 비활성화하고 중지했습니다."
else
    echo "autofs 서비스는 이미 비활성화되어 있습니다."
fi

# 자동 마운트 서비스가 systemd를 사용하지 않는 경우 (선택적 조치)
# service autofs stop
# chkconfig autofs off

echo "U-26 automountd 서비스 비활성화 작업이 완료되었습니다."

# ==== 조치 결과 MD 출력 ====
_change_code="U-26"
_change_item="autofs 서비스가 활성화되어 있습니다. 비활성화를 "
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
