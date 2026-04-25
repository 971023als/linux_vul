#!/usr/bin/python3
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

import subprocess
import re

def check_remote_root_access_restriction():
    results = {
        "분류": "계정관리",
        "코드": "U-01",
        "위험도": "상",
        "진단 항목": "root 계정 원격접속 제한",
        "진단 결과": "양호",  # 기본 값을 "양호"로 가정
        "현황": [],
        "대응방안": "원격 터미널 서비스 사용 시 root 직접 접속을 차단 / /etc/securetty 에서 pts/* 제거"
    }

    # /etc/securetty 점검 (RHEL 계열: 콘솔 root 접속 제한)
    # pts/ 항목이 있으면 원격 터미널에서 root 로그인 허용 → 취약
    securetty = "/etc/securetty"
    try:
        with open(securetty, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith('#') or not line:
                    continue
                if line.startswith('pts/'):
                    results["현황"].append(f"/etc/securetty 에 원격 접속 허용 항목이 있습니다: {line}")
                    results["진단 결과"] = "취약"
    except FileNotFoundError:
        results["현황"].append("/etc/securetty 파일이 없습니다(기본 안전).")
    except Exception as e:
        results["현황"].append(f"/etc/securetty 검사 중 오류 발생: {e}")

    # Telnet 서비스 검사
    try:
        telnet_status = subprocess.run(["grep", "-E", r"telnet\s+\d+/tcp", "/etc/services"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if telnet_status.stdout:
            results["현황"].append("Telnet 서비스 포트가 활성화되어 있습니다.")
            results["진단 결과"] = "취약"
    except Exception as e:
        results["현황"].append(f"Telnet 서비스 검사 중 오류 발생: {e}")

    # SSH 서비스 검사
    # 취약 판정 기준: PermitRootLogin yes 또는 without-password (비밀번호 없이 root 접속 허용)
    # 안전 판정: no, prohibit-password, forced-commands-only
    root_login_restricted = True
    _PERMIT_ROOT_UNSAFE = re.compile(
        r'^\s*PermitRootLogin\s+(yes|without-password)\s*$', re.IGNORECASE
    )
    for sshd_config in subprocess.getoutput("find /etc/ssh -name 'sshd_config'").splitlines():
        try:
            with open(sshd_config, 'r') as file:
                for line in file:
                    if line.strip().startswith('#'):
                        continue
                    if _PERMIT_ROOT_UNSAFE.match(line):
                        root_login_restricted = False
                        break
        except Exception as e:
            results["현황"].append(f"{sshd_config} 파일 읽기 중 오류 발생: {e}")

    if not root_login_restricted:
        results["현황"].append("SSH 서비스에서 root 계정의 원격 접속이 허용되고 있습니다.")
        results["진단 결과"] = "취약"
    else:
        results["현황"].append("SSH 서비스에서 root 계정의 원격 접속이 제한되어 있습니다.")

    return results

def main():
    results = check_remote_root_access_restriction()
    print_as_md(results)

if __name__ == "__main__":
    main()
