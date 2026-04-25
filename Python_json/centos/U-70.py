#!/usr/bin/python3
import subprocess
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


def check_smtp_restrictions():
    results = {
        "분류": "서비스 관리",
        "코드": "U-70",
        "위험도": "중",
        "진단 항목": "expn, vrfy 명령어 제한",
        "진단 결과": "",
        "현황": "",
        "대응방안": "SMTP 설정에서 noexpn 및 novrfy 옵션 활성화"
    }

    # Adjusted for compatibility with Python 3.6
    ps_output = subprocess.run(['ps', '-ef'], stdout=subprocess.PIPE, universal_newlines=True).stdout.lower()
    if 'smtp' not in ps_output and 'sendmail' not in ps_output:
        results["진단 결과"] = "양호"
        results["현황"] = "SMTP 서비스 미사용."
        return results

    # Find sendmail.cf files
    find_command = ['find', '/', '-name', 'sendmail.cf', '-type', 'f']
    find_result = subprocess.run(find_command, stdout=subprocess.PIPE, universal_newlines=True, stderr=subprocess.DEVNULL)
    sendmailcf_files = find_result.stdout.strip().split('\n')

    if not sendmailcf_files or sendmailcf_files == ['']:
        results["진단 결과"] = "취약"
        results["현황"] = "SMTP 서비스 사용 중이나, noexpn, novrfy 또는 goaway 옵션을 설정할 수 있는 sendmail.cf 파일이 없습니다."
    else:
        restriction_found = False
        for file_path in sendmailcf_files:
            try:
                with open(file_path, 'r') as file:
                    content = file.read()
                    if re.search(r'PrivacyOptions.*noexpn', content, re.IGNORECASE) and re.search(r'PrivacyOptions.*novrfy', content, re.IGNORECASE) or re.search(r'PrivacyOptions.*goaway', content, re.IGNORECASE):
                        restriction_found = True
                        break
            except Exception as e:
                # Handling potential exceptions when accessing file content
                continue
        
        if restriction_found:
            results["진단 결과"] = "양호"
            results["현황"] = "SMTP 서비스에서 noexpn 및 novrfy 옵션이 적절히 설정되어 있습니다."
        else:
            results["진단 결과"] = "취약"
            results["현황"] = "일부 sendmail.cf 파일에 noexpn, novrfy 또는 goaway 설정이 적절히 설정되어 있지 않습니다."

    return results

def main():
    smtp_restriction_check_results = check_smtp_restrictions()
    print_as_md(smtp_restriction_check_results)

if __name__ == "__main__":
    main()
