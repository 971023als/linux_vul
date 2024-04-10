#!/usr/bin/python3
import os
import json
import glob

def check_session_timeout():
    results = {
        "분류": "계정관리",
        "코드": "U-54",
        "위험도": "하",
        "진단 항목": "Session Timeout 설정",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "Session Timeout을 600초(10분) 이하로 설정"
    }

    check_files = ["/etc/profile", "/etc/csh.login", "/etc/csh.cshrc"] + glob.glob("/home/*/.profile")
    session_timeout_not_set_or_exceeds = []

    for file_path in check_files:
        if os.path.isfile(file_path):
            with open(file_path, 'r') as file:
                contents = file.read()
                for line in contents.splitlines():
                    if line.strip().startswith("TMOUT") or "autologout" in line:
                        setting, value = line.split("=")
                        value = value.strip()
                        try:
                            value_int = int(value)
                            if setting.strip() == "TMOUT" and value_int > 600:
                                session_timeout_not_set_or_exceeds.append((file_path, "TMOUT", value))
                            elif setting.strip() == "autologout" and value_int > 10:
                                session_timeout_not_set_or_exceeds.append((file_path, "autologout", value))
                        except ValueError:
                            continue  # Skip lines where the value is not an integer

    if session_timeout_not_set_or_exceeds:
        results["진단 결과"] = "취약"
        for file_path, setting, value in session_timeout_not_set_or_exceeds:
            results["현황"].append(f"{file_path} 파일에서 {setting} 설정 값이 {value}로 설정되어 있어 600초(10분) 이하로 설정되지 않았습니다.")
    else:
        results["진단 결과"] = "양호"
        results["현황"].append("모든 검사된 파일에서 세션 타임아웃이 600초(10분) 이하로 적절히 설정되어 있습니다.")

    return results

def main():
    session_timeout_check_results = check_session_timeout()
    print(json.dumps(session_timeout_check_results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
