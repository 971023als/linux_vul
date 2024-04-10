#!/usr/bin/python3
import os
import json

def check_for_unnecessary_groups():
    results = {
        "분류": "계정관리",
        "코드": "U-51",
        "위험도": "하",
        "진단 항목": "계정이 존재하지 않는 GID 금지",
        "진단 결과": "양호",  # Assume "Good" until proven otherwise
        "현황": [],
        "대응방안": "계정이 없는 불필요한 그룹 삭제"
    }

    if os.path.isfile("/etc/group") and os.path.isfile("/etc/passwd"):
        with open("/etc/group", 'r') as group_file:
            groups = group_file.readlines()

        with open("/etc/passwd", 'r') as passwd_file:
            passwd_lines = passwd_file.readlines()

        # Extract GIDs from /etc/passwd
        gids_in_use = set(line.split(":")[3] for line in passwd_lines)

        unnecessary_groups = []
        for group in groups:
            group_fields = group.strip().split(":")
            gid = group_fields[2]
            members = group_fields[3]

            # Check if GID is >= 500 and has no members
            if gid >= "500" and (not members or all(member not in gids_in_use for member in members.split(','))):
                unnecessary_groups.append(group_fields[0])

        if unnecessary_groups:
            results["진단 결과"] = "취약"
            results["현황"].append("계정이 없는 불필요한 그룹이 존재합니다: " + ", ".join(unnecessary_groups))
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("/etc/group 또는 /etc/passwd 파일이 없습니다.")

    return results

def main():
    unnecessary_groups_check_results = check_for_unnecessary_groups()
    print(json.dumps(unnecessary_groups_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
