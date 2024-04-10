#!/bin/bash

start_path="/tmp"
분류="파일 및 디렉터리 관리"
코드="U-06"
위험도="상"
진단_항목="파일 및 디렉터리 소유자 설정"
대응방안="소유자가 존재하지 않는 파일 및 디렉터리가 존재하지 않도록 설정"
진단_결과="양호"
현황="소유자가 존재하지 않는 파일 및 디렉터리가 없습니다."
no_owner_files=()

# 함수: 소유자 없는 파일/디렉터리 찾기
check_no_owner_files() {
    while IFS= read -r -d '' file; do
        # 파일의 소유자와 그룹을 검사하고 없는 경우 배열에 추가
        if ! getent passwd "$(stat -c "%u" "$file")" > /dev/null || \
           ! getent group "$(stat -c "%g" "$file")" > /dev/null; then
            no_owner_files+=("$file")
        fi
    done < <(find "$start_path" -print0)
}

check_no_owner_files

# 결과 설정 및 출력
if [ ${#no_owner_files[@]} -gt 0 ]; then
    진단_결과="취약"
    현황="${no_owner_files[*]}"
fi

echo "분류: $분류"
echo "코드: $코드"
echo "위험도: $위험도"
echo "진단 항목: $진단_항목"
echo "대응방안: $대응방안"
echo "진단 결과: $진단_결과"
if [ "$진단_결과" = "취약" ]; then
    echo "현황: 소유자가 존재하지 않는 파일 및 디렉터리:"
    printf '%s\n' "${no_owner_files[@]}"
else
    echo "현황: $현황"
fi
