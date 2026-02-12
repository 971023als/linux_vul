#!/usr/bin/env python3
import os
import json
import stat

def check_log_directory_permission():

    result = {
        "분류": "로그 관리",
        "코드": "U-67",
        "위험도": "중",
        "진단 항목": "로그 디렉터리 소유자 및 권한 설정",
        "진단 결과": "",
        "현황": "",
        "대응방안": "/var/log 하위 로그파일 소유자 root 및 권한 644 이하 설정"
    }

    log_dirs = [
        "/var/log",
        "/var/adm",
        "/var/adm/syslog"
    ]

    issues = []
    checked = False

    for log_dir in log_dirs:
        if not os.path.exists(log_dir):
            continue

        for root, dirs, files in os.walk(log_dir):
            for name in files:
                file_path = os.path.join(root, name)

                try:
                    st = os.stat(file_path)
                    checked = True

                    owner_uid = st.st_uid
                    perm = oct(st.st_mode & 0o777)

                    # owner check
                    if owner_uid != 0:
                        issues.append(f"{file_path} → 소유자 root 아님")

                    # permission check (644 초과)
                    if (st.st_mode & stat.S_IWOTH):
                        issues.append(f"{file_path} → 기타 사용자 쓰기권한 존재")

                    if int(perm, 8) > 0o644:
                        issues.append(f"{file_path} → 권한 과다({perm})")

                except:
                    continue

    if not checked:
        result["진단 결과"] = "N/A"
        result["현황"] = "로그 파일 점검 대상 없음"
        return result

    if issues:
        result["진단 결과"] = "취약"
        result["현황"] = "\n".join(issues[:20])  # 너무 많으면 20개만
    else:
        result["진단 결과"] = "양호"
        result["현황"] = "로그 파일 권한 및 소유자 설정 양호"

    return result


def main():
    res = check_log_directory_permission()
    print(json.dumps(res, ensure_ascii=False, indent=4))


if __name__ == "__main__":
    main()
