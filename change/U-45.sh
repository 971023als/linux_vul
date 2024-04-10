#!/bin/bash

# /etc/pam.d/su 파일 검사
pam_su_path="/etc/pam.d/su"

# 파일 존재 여부 및 설정 검사
if [ -f "$pam_su_path" ]; then
    # pam_wheel.so 모듈의 적절한 설정 확인
    if grep -q "auth\s*required\s*pam_wheel.so\s*use_uid" "$pam_su_path"; then
        jq '.진단 결과 = "양호" | .현황 += ["su 명령어 사용이 특정 그룹으로 제한되어 있습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    else
        jq '.진단 결과 = "취약" | .현황 += ["/etc/pam.d/su 파일에 pam_wheel.so 모듈 설정이 적절히 구성되지 않았습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
    fi
else
    jq '.진단 결과 = "취약" | .현황 += ["/etc/pam.d/su 파일이 존재하지 않습니다."]' $results_file > tmp.$$.json && mv tmp.$$.json $results_file
fi

# 결과 출력
cat $results_file
