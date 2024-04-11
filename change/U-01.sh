#!/usr/bin/python3
import json
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
        "대응방안": "원격 터미널 서비스 사용 시 root 직접 접속을 차단"
    }

    # Telnet 서비스 검사
    try:
        telnet_status = subprocess.run(["grep", "-E", "telnet\s+\d+/tcp", "/etc/services"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if telnet_status.stdout:
            results["현황"].append("Telnet 서비스 포트가 활성화되어 있습니다.")
            results["진단 결과"] = "취약"
    except Exception as e:
        results["현황"].append(f"Telnet 서비스 검사 중 오류 발생: {e}")

    # SSH 서비스 검사
    root_login_restricted = True  # root 로그인이 제한되었다고 가정
    for sshd_config in subprocess.getoutput("find /etc/ssh -name 'sshd_config'").splitlines():
        try:
            with open(sshd_config, 'r') as file:
                for line in file:
                    if 'PermitRootLogin' in line and not line.strip().startswith('#'):
                        if 'yes' in line or 'without-password' in line or 'prohibit-password' not in line or 'forced-commands-only' not in line:
                            root_login_restricted = False  # root 로그인이 제한되지 않음
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
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
