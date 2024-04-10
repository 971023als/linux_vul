#!/bin/bash

# 패스워드 최소 길이 설정 파일 경로
login_defs="/etc/login.defs"

# login.defs 파일에서 패스워드 최소 길이 설정 검사 및 수정
if [ -f "$login_defs" ]; then
    min_length=$(grep "^PASS_MIN_LEN" $login_defs | awk '{ print $2 }')
    if [ "$min_length" -lt 8 ]; then
        sed -i "/^PASS_MIN_LEN/c\PASS_MIN_LEN    8" $login_defs
        jq '.현황 += ["패스워드 최소 길이가 8자로 설정되었습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    else
        jq '.현황 += ["패스워드 최소 길이가 이미 8자 이상으로 설정되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
else
    jq '.현황 += ["/etc/login.defs 파일이 존재하지 않습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

jq '.진단 결과 = "양호"' $results_file > tmp.$$.json && mv tmp.$$.json $results_file

# 결과 출력
cat $results_file
