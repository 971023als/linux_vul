#!/bin/bash

login_defs_path="/etc/login.defs"

if [ -f "$login_defs_path" ]; then
    while IFS= read -r line; do
        if echo "$line" | grep -q "PASS_MAX_DAYS" && ! echo "$line" | grep -q "^#"; then
            max_days=$(echo "$line" | awk '{print $2}')
            if [ "$max_days" -le 90 ]; then
                # 양호한 경우, 추가적인 조치 필요 없음
                echo "패스워드 최대 사용기간이 $max_days 일로 설정되어 있어 양호합니다."
            else
                jq --arg max_days "$max_days" '.진단 결과 = "취약" | .현황 += ["/etc/login.defs 파일에 패스워드 최대 사용 기간이 90일을 초과하여 " + $max_days + "일로 설정되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
            fi
            break
        fi
    done < "$login_defs_path"
else
    jq '.진단 결과 = "취약" | .현황 += ["/etc/login.defs 파일이 없습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
