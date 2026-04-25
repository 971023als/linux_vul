import os
import pwd
import grp
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


def find_files_without_owners(start_path='/tmp'):
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-06",
        "위험도": "상",
        "진단 항목": "파일 및 디렉터리 소유자 설정",
        "진단 결과": "",
        "현황": [],
        "대응방안": "소유자가 존재하지 않는 파일 및 디렉터리가 존재하지 않도록 설정"
    }

    no_owner_files = []

    try:
        for root, dirs, files in os.walk(start_path, topdown=True):
            for name in files + dirs:
                full_path = os.path.join(root, name)
                try:
                    if pwd.getpwuid(os.stat(full_path).st_uid) is None or \
                       grp.getgrgid(os.stat(full_path).st_gid) is None:
                        no_owner_files.append(full_path)
                except KeyError:
                    no_owner_files.append(full_path)
    except Exception as e:
        results["현황"] = f"스캔 중 오류 발생: {str(e)}"
        results["진단 결과"] = "오류"

    if no_owner_files:
        results["진단 결과"] = "취약"
        results["현황"].append(f"{no_owner_files}입니다.")  # This works as intended now
    else:
        results["진단 결과"] = "양호"
        results["현황"] = ["소유자가 존재하지 않는 파일 및 디렉터리가 존재하지 않습니다."]  # Replace the list's contents instead of append

    return results

def main():
    results = find_files_without_owners()
    print_as_md(results)

if __name__ == "__main__":
    main()
