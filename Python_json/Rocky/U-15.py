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


def find_world_writable_files(start_dir):
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-15",
        "위험도": "상",
        "진단 항목": "world writable 파일 점검",
        "진단 결과": "",
        "현황": [],
        "대응방안": "시스템 중요 파일에 world writable 파일이 존재하지 않거나, 존재 시 설정 이유를 확인"
    }

    # Warning: Using '/' may significantly impact system performance.
    # Consider running on a more specific directory for routine checks.
    # start_dir = '/'  # Uncomment for full system scan
    world_writable_files = []

    for foldername, subfolders, filenames in os.walk(start_dir):
        for filename in filenames:
            filepath = os.path.join(foldername, filename)
            try:
                if os.path.isfile(filepath):  # Ensure it's a file
                    mode = os.stat(filepath).st_mode
                    if mode & stat.S_IWOTH:  # Check world writable flag
                        world_writable_files.append(filepath)
            except Exception as e:
                continue  # Handle inaccessible files gracefully

    if world_writable_files:
        results["진단 결과"] = "취약"
        results["현황"] = world_writable_files
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("world writable 설정이 되어있는 파일이 없습니다.")

    return results

def main():
    # Example directory to check; replace with '/' for a full scan with caution
    start_dir = '/tmp'  
    results = find_world_writable_files(start_dir)
    print_as_md(results)

if __name__ == "__main__":
    main()
