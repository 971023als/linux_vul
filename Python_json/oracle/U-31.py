#!/usr/bin/python3
import subprocess
import os
import re
import json


def print_as_md(results: dict):
    """진단 결과를 Markdown 테이블 형식으로 출력."""
    code   = results.get("코드",     results.get("code", "U-??"))
    item   = results.get("진단 항목", results.get("diagnosisItem", "진단항목"))
    cat    = results.get("분류",     results.get("category", ""))
    risk   = results.get("위험도",   results.get("riskLevel", ""))
    result = results.get("진단 결과", results.get("diagnosisResult", ""))
    status = results.get("현황",     results.get("status", []))
    sol    = results.get("대응방안", results.get("solution", ""))

    if isinstance(status, list):
        status = " / ".join(status) if status else ""

    print(f"# {code}: {item}")
    print("")
    print("| 항목 | 내용 |")
    print("|------|------|")
    print(f"| 분류 | {cat} |")
    print(f"| 코드 | {code} |")
    print(f"| 위험도 | {risk} |")
    print(f"| 진단항목 | {item} |")
    print(f"| 진단결과 | {result} |")
    print(f"| 현황 | {status} |")
    print(f"| 대응방안 | {sol} |")


def check_spam_mail_relay_restrictions():
    results = {
        "분류": "서비스 관리",
        "코드": "U-31",
        "위험도": "상",
        "진단 항목": "스팸 메일 릴레이 제한",
        "진단 결과": None,
        "현황": [],
        "대응방안": "SMTP 서비스 릴레이 제한 설정"
    }

    search_directory = '/etc/mail/'
    cmd = f"find {search_directory} -name 'sendmail.cf' -type f"

    process = subprocess.run(cmd, shell=True, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if process.returncode == 0 and process.stdout:
        sendmail_cf_files = process.stdout.strip().split('\n')
        vulnerable_found = False
        for file_path in sendmail_cf_files:
            if os.path.isfile(file_path):
                with open(file_path, 'r') as file:
                    content = file.read()
                    if re.search(r'R\$\*', content) or re.search(r'Relaying denied', content, re.IGNORECASE):
                        results["현황"].append(f"{file_path} 파일에 릴레이 제한이 적절히 설정되어 있습니다.")
                    else:
                        vulnerable_found = True
                        results["현황"].append(f"{file_path} 파일에 릴레이 제한 설정이 없습니다.")
        if vulnerable_found:
            results["진단 결과"] = "취약"
        else:
            results["진단 결과"] = "양호"
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("sendmail.cf 파일을 찾을 수 없습니다.")

    return results

def main():
    results = check_spam_mail_relay_restrictions()
    print_as_md(results)

if __name__ == "__main__":
    main()
