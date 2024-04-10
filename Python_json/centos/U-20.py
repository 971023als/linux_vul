#!/usr/bin/python3
import json
import pwd

def check_anonymous_ftp():
    results = {
        "분류": "시스템 설정",
        "코드": "U-20",
        "위험도": "상",
        "진단 항목": "Anonymous FTP 비활성화",
        "진단 결과": "",
        "현황": [],
        "대응방안": "Anonymous FTP 비활성화"
    }

    try:
        pwd.getpwnam('ftp')
        results["진단 결과"] = "취약"
        results["현황"].append("FTP 계정이 /etc/passwd 파일에 있습니다.")
    except KeyError:
        results["진단 결과"] = "양호"
        results["현황"].append("FTP 계정이 /etc/passwd 파일에 없습니다.")

    return results

def main():
    results = check_anonymous_ftp()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
