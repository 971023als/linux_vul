#!/usr/bin/python3
import os
import json
from collections import Counter

def check_duplicate_uids():
    results = {
        "분류": "계정관리",
        "코드": "U-52",
        "위험도": "중",
        "진단 항목": "동일한 UID 금지",
        "진단 결과": "양호",
        "현황": [],
        "대응방안": "동일한 UID로 설정된 사용자 계정을 제거하거나 수정"
    }

    min_regular_user_uid = 1000

    if os.path.isfile("/etc/passwd"):
        with open("/etc/passwd", 'r') as file:
            uids = [line.split(":")[2] for line in file if line.strip() and not line.startswith("#") and int(line.split(":")[2]) >= min_regular_user_uid]
            uid_counts = Counter(uids)
            duplicate_uids = {uid: count for uid, count in uid_counts.items() if count > 1}

            if duplicate_uids:
                results["진단 결과"] = "취약"
                duplicates_formatted = ", ".join([f"UID {uid} ({count}x)" for uid, count in duplicate_uids.items()])
                results["현황"].append(f"동일한 UID로 설정된 사용자 계정이 존재합니다: {duplicates_formatted}")
            else:
                results["현황"].append("동일한 UID를 공유하는 사용자 계정이 없습니다.")
    else:
        results["진단 결과"] = "취약"
        results["현황"].append("/etc/passwd 파일이 없습니다.")

    return results

def main():
    duplicate_uids_check_results = check_duplicate_uids()
    print(json.dumps(duplicate_uids_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
