#!/usr/bin/python3
import json
import subprocess

def check_log_review_and_reporting():
    results = {
        "분류": "로그 관리",
        "코드": "U-43",
        "위험도": "상",
        "진단 항목": "로그의 정기적 검토 및 보고",
        "진단 결과": "양호",
        "현황": [],
        "대응방안": "보안 로그, 응용 프로그램 및 시스템 로그 기록의 정기적 검토, 분석, 리포트 작성 및 보고 조치 실행"
    }

    log_files = {
        "UTMP": "/var/log/utmp",
        "WTMP": "/var/log/wtmp",
        "BTMP": "/var/log/btmp",
        "SULOG": "/var/log/sulog",
        "XFERLOG": "/var/log/xferlog"
    }

    for log_name, log_path in log_files.items():
        if check_file_existence(log_path):
            results["현황"].append({"파일명": log_name, "결과": "존재함"})
        else:
            results["현황"].append({"파일명": log_name, "결과": "존재하지 않음"})

    return results

def check_file_existence(file_path):
    try:
        with open(file_path, 'r'):
            return True
    except FileNotFoundError:
        return False

def main():
    results = check_log_review_and_reporting()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
