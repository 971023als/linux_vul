#!/bin/bash

# 백업 디렉터리 생성
mkdir -p "$backup_path"

# 숨겨진 파일 및 디렉터리 검색 및 백업 후 삭제
find "$start_path" -name ".*" -print0 | while IFS= read -r -d '' file; do
    # 백업 파일/디렉터리 경로 생성
    backup_file="$backup_path$(echo "$file" | sed "s|^$HOME/||")"
    backup_dir=$(dirname "$backup_file")
    
    # 백업 디렉터리 생성
    mkdir -p "$backup_dir"
    
    # 파일/디렉터리를 백업 디렉터리로 복사
    if [[ -f "$file" ]]; then
        cp "$file" "$backup_file"
    elif [[ -d "$file" ]]; then
        cp -r "$file" "$backup_dir"
    fi
    
    # 원본 파일/디렉터리 삭제
    rm -rf "$file"
done

echo "숨겨진 파일 및 디렉터리가 백업 및 삭제되었습니다."
echo "백업 위치: $backup_path"
