#!/usr/bin/python3
import os
import json
import subprocess

def check_sendmail_execution_restriction():
    results = {
        "분류": "서비스 관리",
        "코드": "U-32",
        "위험도": "상",
        "진단 항목": "일반사용자의 Sendmail 실행 방지",
        "진단 결과": None,
        "현황": [],
        "대응방안": "SMTP 서비스 미사용 또는 일반 사용자의 Sendmail 실행 방지 설정"
    }

    try:
        sendmail_cf_files = subprocess.check_output("find / -name 'sendmail.cf' -type f 2>/dev/null", shell=True, text=True).strip().split('\n')
        no_restriction_files = []

        for file_path in sendmail_cf_files:
            if file_path:
                with open(file_path, 'r') as file:
                    for line in file:
                        if 'restrictqrun' in line and not line.strip().startswith('#'):
                            break
                    else:
                        no_restriction_files.append(file_path)

        if no_restriction_files:
            results["진단 결과"] = "취약"
            for file_path in no_restriction_files:
                results["진단 결과"] = "취약"
                results["현황"].append(f"{file_path} 파일에 restrictqrun 옵션이 설정되어 있지 않습니다.")
        else:
            results["진단 결과"] = "양호"
            results["현황"].append("모든 sendmail.cf 파일에 restrictqrun 옵션이 적절히 설정되어 있습니다.")

    except subprocess.CalledProcessError as e:
        results["진단 결과"] = "오류"
        results["현황"].append(f"sendmail.cf 파일 검색 중 오류 발생: {e}")

    return results

def main():
    # 함수 실행
    result = check_sendmail_execution_restriction()
    print(json.dumps(result, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
