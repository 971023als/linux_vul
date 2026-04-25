#!/usr/bin/python3
import os
import stat
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


def check_dev_directory_for_non_device_files():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-16",
        "위험도": "상",
        "진단 항목": "/dev에 존재하지 않는 device 파일 점검",
        "진단 결과": "",  # 초기 상태를 설정하지 않음
        "현황": [],
        "대응방안": "/dev에 대한 파일 점검 후 존재하지 않은 device 파일을 제거한 경우"
    }

    dev_directory = '/dev'
    non_device_files = []

    for item in os.listdir(dev_directory):
        item_path = os.path.join(dev_directory, item)
        if os.path.isfile(item_path):
            mode = os.stat(item_path).st_mode
            if not stat.S_ISCHR(mode) and not stat.S_ISBLK(mode):
                non_device_files.append(item_path)

    if non_device_files:
        results["진단 결과"] = "취약"
        results["현황"].append(" $non_device_files 장치가 존재합니다")
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("/dev 디렉터리에 존재하지 않는 device 파일이 없습니다.")

    return results

def main():
    results = check_dev_directory_for_non_device_files()
    print_as_md(results)

if __name__ == "__main__":
    main()
