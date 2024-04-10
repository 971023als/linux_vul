import os
import pwd
import grp
import json

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
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
