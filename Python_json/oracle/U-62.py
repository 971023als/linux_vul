#!/usr/bin/python3
import subprocess
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


def check_ftp_account_shell_restriction():
    # 초기 진단 결과 및 현황 설정
    results = {
        "분류": "서비스 관리",
        "코드": "U-62",
        "위험도": "중",
        "진단 항목": "ftp 계정 shell 제한",
        "진단 결과": "",  # 초기 값 설정하지 않음
        "현황": "",
        "대응방안": "ftp 계정에 /bin/false 쉘 부여"
    }

    ftp_account_found = False  # ftp 계정 존재 여부

    try:
        with open('/etc/passwd', 'r') as passwd_file:
            for line in passwd_file:
                fields = line.strip().split(':')
                # FTP 계정을 찾았는지 확인
                if fields[0] == 'ftp':
                    ftp_account_found = True
                    # FTP 계정의 쉘이 /bin/false로 설정되어 있는지 확인
                    if fields[-1] == '/bin/false':
                        results["진단 결과"] = "양호"
                        results["현황"] = "ftp 계정에 /bin/false 쉘이 부여되어 있습니다."
                    else:
                        results["진단 결과"] = "취약"
                        results["현황"] = "ftp 계정에 /bin/false 쉘이 부여되어 있지 않습니다."
                    break
    except FileNotFoundError:
        results["현황"] = "/etc/passwd 파일을 찾을 수 없습니다."
        results["진단 결과"] = "취약"

    # FTP 계정이 발견되지 않은 경우
    if not ftp_account_found:
        results["진단 결과"] = "양호"
        results["현황"] = "ftp 계정이 시스템에 존재하지 않습니다."

    return results

def main():
    ftp_shell_restriction_check_results = check_ftp_account_shell_restriction()
    print_as_md(ftp_shell_restriction_check_results)

if __name__ == "__main__":
    main()
