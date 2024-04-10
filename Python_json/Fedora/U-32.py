#!/usr/bin/python3
import subprocess
import os
import json

def check_sendmail_execution_restriction():
    results = {
        "분류": "서비스 관리",
        "코드": "U-32",
        "위험도": "상",
        "진단 항목": "일반사용자의 Sendmail 실행 방지",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "SMTP 서비스 미사용 또는 일반 사용자의 Sendmail 실행 방지 설정"
    }

    try:
        # sendmail.cf 파일들 찾기
        sendmail_cf_files = subprocess.check_output("find / -name 'sendmail.cf' -type f 2>/dev/null", shell=True, universal_newlines=True).strip().split('\n')

        restriction_set = False
        for file_path in sendmail_cf_files:
            if file_path:  # 파일 경로가 비어 있지 않은 경우
                with open(file_path, 'r') as file:
                    for line in file:
                        if 'restrictqrun' in line and not line.strip().startswith('#'):
                            restriction_set = True
                            break
                if restriction_set:
                    results["현황"].append(f"{file_path} 파일에 restrictqrun 옵션이 설정되어 있습니다.")
                    break

        if restriction_set:
            results["진단 결과"] = "양호"
            if not results["현황"]:
                results["현황"].append("모든 sendmail.cf 파일에 restrictqrun 옵션이 적절히 설정되어 있습니다.")
        else:
            results["진단 결과"] = "취약"
            if not results["현황"]:
                results["현황"].append("sendmail.cf 파일 중 restrictqrun 옵션이 설정되어 있지 않은 파일이 있습니다.")

    except subprocess.CalledProcessError as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"sendmail.cf 파일 검색 중 오류 발생: {e}")

    # 진단 결과가 명시적으로 설정되지 않은 경우 기본값을 "양호"로 설정
    if results["진단 결과"] is None:
        results["진단 결과"] = "양호"
        results["현황"].append("sendmail.cf 파일에 대한 검사를 수행할 수 없습니다.")

    return results

def main():
    results = check_sendmail_execution_restriction()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
