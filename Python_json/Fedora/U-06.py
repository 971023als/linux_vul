#!/usr/bin/python3
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
        "진단 결과": "양호",  # 초기 상태를 양호로 설정
        "현황": [],
        "대응방안": "소유자가 존재하지 않는 파일 및 디렉터리가 존재하지 않도록 설정"
    }

    no_owner_files = []

    try:
        for root, dirs, files in os.walk(start_path, topdown=True):
            for name in files + dirs:
                full_path = os.path.join(root, name)
                try:
                    # 파일 또는 디렉터리의 소유자 정보를 검사합니다.
                    pwd.getpwuid(os.stat(full_path).st_uid)
                    grp.getgrgid(os.stat(full_path).st_gid)
                except KeyError:
                    # 소유자 또는 그룹이 존재하지 않는 경우 목록에 추가합니다.
                    no_owner_files.append(full_path)
    except Exception as e:
        results["현황"] = f"스캔 중 오류 발생: {str(e)}"
        results["진단 결과"] = "오류"

    if no_owner_files:
        results["진단 결과"] = "취약"
        results["현황"].extend(no_owner_files)  # 현황에 파일 목록을 추가합니다.
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("소유자가 존재하지 않는 파일 및 디렉터리가 없습니다.")

    return results

def main():
    results = find_files_without_owners()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
