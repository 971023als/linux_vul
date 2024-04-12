#!/bin/bash

# 세션 타임아웃을 600초(10분) 이하로 설정하는 스크립트
set_session_timeout() {
    echo "세션 타임아웃 설정 조치 시작..."

    # 세션 타임아웃 설정할 파일 목록
    declare -a files=("/etc/profile" "/etc/bash.bashrc")

    # 세션 타임아웃 설정값
    timeout_value=600  # 600초 (10분)

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "$file 파일을 조치합니다."
            if ! grep -q "readonly TMOUT" "$file"; then
                echo "export TMOUT=$timeout_value" >> "$file"
                echo "readonly TMOUT" >> "$file"
                echo "export HISTFILE" >> "$file"
                echo "$file 파일에 세션 타임아웃 설정을 추가했습니다."
            else
                echo "$file 파일에 이미 세션 타임아웃 설정이 존재합니다."
            fi
        else
            echo "$file 파일이 존재하지 않습니다. 건너뜁니다."
        fi
    done

    echo "U-54 모든 조치 완료."
}

main() {
    set_session_timeout
}

main
