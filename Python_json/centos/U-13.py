#!/usr/bin/python3
import os
import stat
import json
import sys

# Python3에서 표준 출력의 인코딩 설정 코드 제거
# Python 3.6에서는 sys.stdout.reconfigure 지원 안 함

def check_suid_sgid_permissions():
    results = {
        "분류": "파일 및 디렉터리 관리",
        "코드": "U-13",
        "위험도": "상",
        "진단 항목": "SUID, SGID 설정 파일 점검",
        "진단 결과": "",  # 초기 진단 결과 설정하지 않음
        "현황": [],
        "대응방안": "주요 실행파일의 권한에 SUID와 SGID에 대한 설정이 부여되어 있지 않은 경우"
    }

    executables = [
        "/sbin/dump", "/sbin/restore", "/sbin/unix_chkpwd",
        "/usr/bin/at", "/usr/bin/lpq", "/usr/bin/lpq-lpd",
        "/usr/bin/lpr", "/usr/bin/lpr-lpd", "/usr/bin/lprm",
        "/usr/bin/lprm-lpd", "/usr/bin/newgrp", "/usr/sbin/lpc",
        "/usr/sbin/lpc-lpd", "/usr/sbin/traceroute"
    ]

    vulnerable_files = []

    for executable in executables:
        if os.path.isfile(executable):
            mode = os.stat(executable).st_mode
            if mode & (stat.S_ISUID | stat.S_ISGID):
                vulnerable_files.append({
                    "\n파일 경로": executable,
                    "SUID 설정": bool(mode & stat.S_ISUID),
                    "SGID 설정": bool(mode & stat.S_ISGID)
                })

    if vulnerable_files:
        results["진단 결과"] = "취약"
        results["현황"] = vulnerable_files
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("SUID나 SGID에 대한 설정이 부여된 주요 실행 파일이 없습니다.")

    return results

def main():
    suid_sgid_permissions_check_results = check_suid_sgid_permissions()
    # 결과를 콘솔에 출력할 때
    print(json.dumps(suid_sgid_permissions_check_results, ensure_ascii=False, indent=4))
    # 결과를 파일에 쓸 때
    with open('suid_sgid_check_results.json', 'w', encoding='utf-8') as f:
        json.dump(suid_sgid_permissions_check_results, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main()
