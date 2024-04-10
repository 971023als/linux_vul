#!/bin/bash

# Apache 서버 루트 디렉터리 검색 및 불필요한 파일 제거
server_root=$(apache2ctl -V | grep 'SERVER_CONFIG_FILE' | cut -d'=' -f2 | xargs dirname)
unwanted_dirs=("$server_root/manual")

removed_items=()
for dir in "${unwanted_dirs[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        removed_items+=("$dir")
    fi
done


# 결과 출력
cat $results_file
