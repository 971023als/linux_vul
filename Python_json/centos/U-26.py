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


def check_automountd_disabled():
    results = {
        "분류": "서비스 관리",
        "코드": "U-26",
        "위험도": "상",
        "진단 항목": "automountd 제거",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "automountd 서비스 비활성화"
    }

    cmd = "ps -ef | grep -iE '[a]utomount|[a]utofs'"
    process = subprocess.run(cmd, shell=True, text=True, capture_output=True)

    if process.returncode == 0:
        # automountd 또는 autofs 서비스가 실행 중임
        results["진단 결과"] = "취약"
        results["현황"].append("automountd 서비스가 실행 중입니다.")
    elif process.returncode == 1:
        # automountd 또는 autofs 서비스가 실행 중이지 않음
        results["진단 결과"] = "양호"
        results["현황"].append("automountd 서비스가 비활성화되어 있습니다.")
    else:
        # 명령어 실행 중 오류 발생
        results["진단 결과"] = "오류"
        results["현황"].append(f"automountd 서비스 확인 중 오류 발생: {process.stderr}")

    return results

def main():
    results = check_automountd_disabled()
    print_as_md(results)

if __name__ == "__main__":
    main()
