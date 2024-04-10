#!/bin/bash

# 변수 초기화
results=""
vulnerability_found=false
category="파일 및 디렉토리 관리"
code="U-59"
severity="하"
check_item="숨겨진 파일 및 디렉터리 검색 및 제거"
declare -a hidden_files
declare -a hidden_dirs
recommendation="불필요하거나 의심스러운 숨겨진 파일 및 디렉터리 삭제"

# 시작 경로 설정, 예를 들어 사용자의 홈 디렉터리
start_path="$HOME"

# 숨겨진 파일 및 디렉터리 검색
while IFS= read -r -d '' file; do
    if [[ -f "$file" ]]; then
        hidden_files+=("$file")
    elif [[ -d "$file" ]]; then
        hidden_dirs+=("$file")
    fi
done < <(find "$start_path" -name ".*" -print0)

# 진단 결과 업데이트
if [ ${#hidden_files[@]} -eq 0 ] && [ ${#hidden_dirs[@]} -eq 0 ]; then
    result="양호"
    status=("숨겨진 파일이나 디렉터리가 없습니다.")
else
    vulnerability_found=true
    result="취약"
    status=("숨겨진 파일 및 디렉터리 발견:")
fi

# 결과 출력
echo "분류: $category"
echo "코드: $code"
echo "위험도: $severity"
echo "진단 항목: $check_item"
echo "진단 결과: $result"
echo "현황:"
if $vulnerability_found; then
    if [ ${#hidden_files[@]} -gt 0 ]; then
        echo "숨겨진 파일:"
        for file in "${hidden_files[@]}"; do
            echo "- $file"
        done
    fi
    if [ ${#hidden_dirs[@]} -gt 0 ]; then
        echo "숨겨진 디렉터리:"
        for dir in "${hidden_dirs[@]}"; do
            echo "- $dir"
        done
    fi
else
    echo "- ${status[@]}"
fi
echo "대응방안: $recommendation"
