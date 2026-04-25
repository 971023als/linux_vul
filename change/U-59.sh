#!/bin/bash

# 숨겨진 파일 및 디렉터리를 검색하고 제거하는 스크립트

# 시작 경로 설정. 예: 홈 디렉터리
start_path="$HOME"

# 숨겨진 파일 및 디렉터리 검색
find_hidden_items() {
    echo "숨겨진 파일 및 디렉터리 검색 중..."
    find "$start_path" -name ".*" -print
}

# 숨겨진 항목 제거 함수
# 실제 운영 환경에서 사용 전에 주의 깊게 검토해야 합니다.
remove_hidden_items() {
    echo "삭제할 숨겨진 파일 또는 디렉터리의 정확한 경로를 입력하세요:"
    read item_path

    # 항목 존재 여부 확인
    if [ -e "$item_path" ]; then
        # 파일 또는 디렉터리 삭제
        rm -r "$item_path"
        echo "$item_path 삭제됨."
    else
        echo "U-59 해당 경로에 항목이 존재하지 않습니다: $item_path"
    fi
}

main() {
    find_hidden_items
    # 숨겨진 항목을 수동으로 삭제하려면 아래 함수의 주석을 해제하십시오.
    # 주의: 이 작업은 위험할 수 있으므로, 항상 주의해서 실행하십시오.
    # remove_hidden_items
}

main

# ==== 조치 결과 MD 출력 ====
_change_code="U-59"
_change_item="숨겨진 파일 및 디렉터리 검색 중..."
cat << __CHANGE_MD__
# ${_change_code}: ${_change_item} — 조치 완료

| 항목 | 내용 |
|------|------|
| 코드 | ${_change_code} |
| 진단항목 | ${_change_item} |
| 조치결과 | 조치 스크립트 실행 완료 |
| 실행일시 | $(date '+%Y-%m-%d %H:%M:%S') |
__CHANGE_MD__
