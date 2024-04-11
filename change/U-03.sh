#!/bin/bash

# 설정 파일과 모듈 정의
FILES_TO_CHECK=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
DENY_MODULES=("pam_tally2.so" "pam_faillock.so")
DENY_THRESHOLD=10

for file_path in "${FILES_TO_CHECK[@]}"; do
    echo "파일 검사 중: $file_path"
    if [ -f "$file_path" ]; then
        for deny_module in "${DENY_MODULES[@]}"; do
            if grep -q "$deny_module" "$file_path" ; then
                # deny 값이 설정된 행 찾기
                DENY_LINE=$(grep "$deny_module.*deny=" "$file_path")
                if [ -n "$DENY_LINE" ]; then
                    # 현재 설정된 deny 값 추출
                    CURRENT_DENY=$(echo "$DENY_LINE" | sed -r 's/.*deny=([0-9]+).*/\1/')
                    if [ "$CURRENT_DENY" -le "$DENY_THRESHOLD" ]; then
                        echo "$file_path 에서 $deny_module 설정이 양호합니다. 현재 임계값: $CURRENT_DENY"
                    else
                        echo "$file_path 에서 $deny_module 설정이 취약합니다. 임계값 조정 필요. 현재 임계값: $CURRENT_DENY"
                        # 필요한 경우, 여기에 자동 조정 로직 추가
                    fi
                else
                    echo "$file_path 에서 $deny_module 모듈에 대한 'deny' 설정이 발견되지 않았습니다."
                    # deny 설정 추가
                    echo "auth required $deny_module deny=$DENY_THRESHOLD unlock_time=900" >> "$file_path"
                    echo "'deny' 설정을 추가했습니다."
                fi
            else
                echo "$file_path 에서 $deny_module 모듈이 사용되지 않고 있습니다."
                # 모듈 사용 설정 추가 필요 시 로직 추가
            fi
        done
    else
        echo "$file_path 파일이 존재하지 않습니다."
    fi
done

echo "U-03 계정 잠금 임계값 설정 검사 및 조정이 완료되었습니다."
