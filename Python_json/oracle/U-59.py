#!/usr/bin/python3
import os
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


def search_hidden_files_and_directories(start_path):
    results = {
        "분류": "파일 및 디렉토리 관리",
        "코드": "U-59",
        "위험도": "하",
        "진단 항목": "숨겨진 파일 및 디렉토리 검색 및 제거",
        "진단 결과": "",  # 초기 값 설정하지 않음
        "현황": {"숨겨진 파일": [], "숨겨진 디렉터리": []},
        "대응방안": "불필요하거나 의심스러운 숨겨진 파일 및 디렉터리 삭제"
    }

    # Walk through the directory
    for root, dirs, files in os.walk(start_path):
        # Check each file
        for file in files:
            if file.startswith('.'):
                results["현황"]["숨겨진 파일"].append(os.path.join(root, file))
        
        # Check each directory
        for dir in dirs:
            if dir.startswith('.'):
                results["현황"]["숨겨진 디렉터리"].append(os.path.join(root, dir))

    # 진단 결과 업데이트
    if not results["현황"]["숨겨진 파일"] and not results["현황"]["숨겨진 디렉터리"]:
        results["진단 결과"] = "양호"
        results["현황"] = "숨겨진 파일이나 디렉터리가 없습니다."
    else:
        results["진단 결과"] = "취약"
        if not results["현황"]["숨겨진 파일"]:
            del results["현황"]["숨겨진 파일"]
        if not results["현황"]["숨겨진 디렉터리"]:
            del results["현황"]["숨겨진 디렉터리"]

    return results

def main():
    # Example: search in the current user's home directory
    home_directory = os.path.expanduser('~')
    hidden_items_check_results = search_hidden_files_and_directories(home_directory)
    print_as_md(hidden_items_check_results)

if __name__ == "__main__":
    main()
