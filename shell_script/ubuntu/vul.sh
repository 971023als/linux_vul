#!/bin/bash

# 초기 설정
declare -A OS_PACKAGE_MANAGER=(
    [debian]="apt-get"
    [ubuntu]="apt-get"
    [centos]="yum"
    [rhel]="yum"
    [fedora]="dnf"
)

declare -A OS_PACKAGES=(
    [debian]="apache2 libapache2-mod-wsgi-py3 python3-venv"
    [ubuntu]="apache2 libapache2-mod-wsgi-py3 python3-venv"
    [centos]="httpd mod_wsgi python3"
    [rhel]="httpd mod_wsgi python3"
    [fedora]="httpd mod_wsgi python3-virtualenv"
)

# 스크립트가 실제 위치한 디렉터리 (cron에서도 cwd와 무관하게 동작)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# cron 명령에서는 %가 특수문자(개행)로 해석되므로 경로에 포함되면 등록하지 않음
if [[ "$SCRIPT_DIR" == *%* ]]; then
    echo "스크립트 경로에 %가 포함되어 cron 등록이 불가능합니다: $SCRIPT_DIR"
    exit 1
fi
CRON_JOB="/bin/bash \"${SCRIPT_DIR}/vul.sh\""
NOW=$(date +'%Y-%m-%d_%H-%M-%S')
WEB_DIRECTORY="/var/www/html"
# 점검 결과(JSON/CSV/에러 로그/HTML 리포트)는 웹 공개 디렉터리에 두지 않고
# 로컬 전용 경로에 저장 (RESULTS_DIRECTORY 환경변수로 변경 가능)
RESULTS_DIRECTORY="${RESULTS_DIRECTORY:-/var/lib/linux_vul/results}"
RESULTS_PATH="${RESULTS_DIRECTORY}/results_${NOW}.json"
ERRORS_PATH="${RESULTS_DIRECTORY}/errors_${NOW}.log"
CSV_PATH="${RESULTS_DIRECTORY}/results_${NOW}.csv"
HTML_PATH="${RESULTS_DIRECTORY}/report_${NOW}.html"

# 운영체제 확인 및 패키지 관리자 설정
setup_environment() {
    if [ ! -f /etc/os-release ]; then
        echo "/etc/os-release 파일을 찾을 수 없습니다. 리눅스 배포판을 확인할 수 없습니다."
        exit 1
    fi

    source /etc/os-release
    PKG_MANAGER=${OS_PACKAGE_MANAGER[$ID]}
    PACKAGES=${OS_PACKAGES[$ID]}
    if [ -z "$PKG_MANAGER" ] || [ -z "$PACKAGES" ]; then
        echo "지원되지 않는 리눅스 배포판입니다."
        exit 1
    fi

    # CentOS/RHEL 8+ 버전일 경우 패키지 매니저를 dnf로 설정
    if { [ "$ID" == "centos" ] || [ "$ID" == "rhel" ]; } && [ "${VERSION_ID%%.*}" -ge 8 ]; then
        PKG_MANAGER="dnf"
    fi

    install_packages
}

# 필요 패키지 설치 전 sudo 권한 확인
check_sudo() {
    if ! sudo -v; then
        echo "이 스크립트를 실행하기 위해서는 sudo 권한이 필요합니다."
        exit 1
    fi
}

install_packages() {
    check_sudo
    echo "필요한 패키지를 설치합니다: $PACKAGES"

    # 패키지 메타데이터만 갱신 (시스템 전체 업그레이드 방지)
    if [ "$PKG_MANAGER" == "yum" ] || [ "$PKG_MANAGER" == "dnf" ]; then
        sudo $PKG_MANAGER makecache
    else
        sudo $PKG_MANAGER update
    fi

    for PACKAGE in $PACKAGES; do
        sudo $PKG_MANAGER install "$PACKAGE" -y || { echo "$PACKAGE 패키지 설치 실패"; exit 1; }
    done

    setup_cron_job
}

# Cron 작업 설정 및 cronie 패키지 설치
setup_cron_job() {
    # crontab 명령이 존재하는지 확인
    if ! command -v crontab &> /dev/null; then
        echo "crontab 명령을 찾을 수 없습니다. cronie 패키지를 설치합니다."
        sudo $PKG_MANAGER install cronie -y
        sudo systemctl enable crond.service
        sudo systemctl start crond.service
    fi

    # Cron 작업 추가
    (crontab -l 2>/dev/null | grep -Fq "$CRON_JOB") && echo "Cron job이 이미 존재합니다." || {
        (crontab -l 2>/dev/null; echo "0 0 * * * $CRON_JOB # 매일 스크립트 실행") | crontab - &&
        echo "Cron job을 추가했습니다." || {
            echo "Cron job 추가에 실패했습니다. crontab이 설정되어 있는지 확인해주세요."
            exit 1
        }
    }
}



# Apache 인코딩 설정
setup_apache_encoding() {
    echo "Apache 인코딩 설정 시작..."
    local apache_config

    # 운영체제별 Apache 설정 파일 경로 지정
    echo "현재 운영 체제: $ID"
    if [[ "$ID" == "debian" ]] || [[ "$ID" == "ubuntu" ]]; then
        apache_config="/etc/apache2/apache2.conf"
        echo "Debian/Ubuntu 시스템 감지됨. Apache 설정 파일: $apache_config"
    elif [[ "$ID" == "centos" ]] || [[ "$ID" == "rhel" ]] || [[ "$ID" == "fedora" ]]; then
        apache_config="/etc/httpd/conf/httpd.conf"
        echo "CentOS/RHEL/Fedora 시스템 감지됨. Apache 설정 파일: $apache_config"
    else
        echo "지원되지 않는 리눅스 배포판입니다. Apache 설정 파일 경로를 수동으로 지정해야 합니다."
        return 1
    fi

    # UTF-8 설정 추가
    echo "Apache 설정 파일에 UTF-8 charset 설정을 검사합니다."
    if grep -q "AddDefaultCharset UTF-8" "$apache_config"; then
        echo "UTF-8 charset 설정이 이미 존재합니다. 추가 작업 없음."
    else
        echo "Apache 설정 파일에 UTF-8 charset 설정이 존재하지 않습니다. 설정을 추가합니다."
        if echo "AddDefaultCharset UTF-8" | sudo tee -a "$apache_config" > /dev/null; then
            echo "Apache 설정 파일에 UTF-8 charset 설정을 성공적으로 추가했습니다."
        else
            echo "Apache 설정 파일 수정 중 오류가 발생했습니다. 관리자 권한이 있는지 확인해주세요."
            return 1
        fi
    fi

    echo "Apache 인코딩 설정 완료."
}

# 이전 버전이 웹 루트에 남긴 결과 파일 경고 (자동 삭제는 하지 않음)
check_legacy_web_artifacts() {
    local legacy_files
    legacy_files=$(ls "${WEB_DIRECTORY}"/results_*.json "${WEB_DIRECTORY}"/results_*.csv "${WEB_DIRECTORY}"/errors_*.log 2>/dev/null)
    if [ -n "$legacy_files" ]; then
        echo "[주의] 이전 실행 결과가 ${WEB_DIRECTORY}에 남아 있어 외부에 노출될 수 있습니다:"
        echo "$legacy_files"
        echo "[주의] 이 스크립트는 자동으로 삭제하지 않습니다. 수동으로 삭제하거나 이동해주세요."
    fi
    if [ -f "${WEB_DIRECTORY}/index.html" ]; then
        echo "[주의] ${WEB_DIRECTORY}/index.html이 존재합니다. 이전 버전이 생성한 점검 리포트라면 외부에 노출 중일 수 있으니 확인 후 수동으로 삭제/이동해주세요."
    fi
}

# 결과 디렉터리 준비 (로컬 전용, 실패 시 중단)
prepare_results_directory() {
    if [ -L "$RESULTS_DIRECTORY" ]; then
        echo "결과 디렉터리가 심볼릭 링크입니다: $RESULTS_DIRECTORY (안전을 위해 중단합니다)"
        exit 1
    fi
    if ! mkdir -p "$RESULTS_DIRECTORY"; then
        echo "결과 디렉터리를 생성할 수 없습니다: $RESULTS_DIRECTORY (권한을 확인해주세요)"
        exit 1
    fi
    # 진단 결과는 민감 정보를 포함하므로 소유자만 접근 가능하게 설정
    chmod 700 "$RESULTS_DIRECTORY" 2>/dev/null
    rm -f "${RESULTS_DIRECTORY}/.write_test"
    if ! touch "${RESULTS_DIRECTORY}/.write_test" 2>/dev/null; then
        echo "결과 디렉터리에 쓸 수 없습니다: $RESULTS_DIRECTORY (권한을 확인해주세요)"
        exit 1
    fi
    rm -f "${RESULTS_DIRECTORY}/.write_test"
}

# 보안 점검 스크립트 실행 및 결과 처리
execute_security_checks() {
    prepare_results_directory
    if ! echo "[" > "$RESULTS_PATH"; then
        echo "결과 파일을 기록할 수 없습니다: $RESULTS_PATH"
        exit 1
    fi
    declare -a errors
    first_entry=true

    for i in $(seq -f "%02g" 1 72); do
        SCRIPT_PATH="${SCRIPT_DIR}/U-$i.sh"
        if [ -f "$SCRIPT_PATH" ]; then
            RESULT=$(bash "${SCRIPT_DIR}/../../runners/shell_runner.sh" --check "U-$i" --script "$SCRIPT_PATH" 2>>"$ERRORS_PATH")
            if [ $? -ne 0 ]; then
                errors+=("Error running $SCRIPT_PATH")
                continue
            fi
            # 출력이 JSON 객체(필드 이름/값 쌍)가 아니면 변환기가 기대하는 형식과 달라
            # 결과 파일이 깨지므로 건너뛰고 기록
            if ! echo "$RESULT" | python3 -c "import sys, json; v = json.load(sys.stdin); sys.exit(0 if isinstance(v, dict) else 1)" 2>/dev/null; then
                echo "[$SCRIPT_PATH] JSON 객체 형식의 출력이 아니어서 결과에서 제외했습니다." >> "$ERRORS_PATH"
                errors+=("$SCRIPT_PATH did not return a JSON object")
                continue
            fi
            [ "$first_entry" = false ] && echo "," >> "$RESULTS_PATH"
            first_entry=false
            echo "$RESULT" >> "$RESULTS_PATH"
        else
            errors+=("$SCRIPT_PATH not found")
        fi
    done
    echo "]" >> "$RESULTS_PATH"

    if [ ${#errors[@]} -gt 0 ]; then
        printf "%s\n" "${errors[@]}" >> "$ERRORS_PATH"
        echo "에러가 존재함 -> $ERRORS_PATH"
    else
        echo "에러 없음."
    fi
}

convert_results() {
    python3 -c "
import json
import csv
import html
from pathlib import Path

json_path = Path('$RESULTS_PATH')
csv_path = Path('$CSV_PATH')
html_path = Path('$HTML_PATH')

def load_results():
    try:
        with json_path.open('r', encoding='utf-8') as json_file:
            data = json.load(json_file)
    except (ValueError, OSError) as e:
        print(f'결과 JSON을 읽을 수 없습니다: {e}')
        return []
    if not isinstance(data, list):
        return []
    # 객체만 처리 (배열/문자열 등 다른 형식은 제외)
    return [item for item in data if isinstance(item, dict)]

def collect_fieldnames(data):
    fieldnames = []
    for item in data:
        for key in item.keys():
            if key not in fieldnames:
                fieldnames.append(key)
    return fieldnames

def json_to_csv(data, fieldnames):
    with csv_path.open('w', newline='', encoding='utf-8-sig') as csv_file:
        if data and fieldnames:
            writer = csv.DictWriter(csv_file, fieldnames=fieldnames, restval='', extrasaction='ignore')
            writer.writeheader()
            writer.writerows(data)

def json_to_html(data, fieldnames):
    with html_path.open('w', encoding='utf-8') as html_file:
        html_file.write('''
<!DOCTYPE html>
<html>
<head>
    <title>Security Check Results</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        h1 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            text-align: left;
            padding: 8px;
            border: 1px solid #ddd;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>Security Check Results</h1>
    <p>CSV 파일 위치: ''' + str(csv_path) + '''</p>
    <table>''')
        if data and fieldnames:
            html_file.write('<tr>' + ''.join(f'<th>{html.escape(str(h))}</th>' for h in fieldnames) + '</tr>')
            for item in data:
                row = '<tr>' + ''.join(f'<td>{html.escape(str(item.get(h, \"\")))}</td>' for h in fieldnames) + '</tr>'
                html_file.write(row)
        html_file.write('</table></body></html>')

data = load_results()
fieldnames = collect_fieldnames(data)
json_to_csv(data, fieldnames)
json_to_html(data, fieldnames)
"
    echo "결과가 CSV와 HTML 형식으로 변환되었습니다: $HTML_PATH"
}


# Apache 서비스 재시작 개선된 버전
restart_apache() {
    local service_names=("apache2.service" "httpd.service") # 서비스 파일 이름 명시
    local service_found=false

    for name in "${service_names[@]}"; do
        # 시스템에 서비스 파일이 존재하는지 확인
        if systemctl list-unit-files | grep -qw "$name"; then
            echo "$name 서비스를 재시작합니다."
            if sudo systemctl restart "$name"; then
                echo "$name 서비스가 성공적으로 재시작되었습니다."
                service_found=true
                break
            else
                echo "$name 서비스 재시작에 실패했습니다."
            fi
        fi
    done

    if [ "$service_found" = false ]; then
        echo "Apache/Httpd 서비스를 찾을 수 없습니다. 시스템에 서비스가 설치되어 있는지 확인해주세요."
    fi
}



# 메인 로직 실행
main() {
    setup_environment
    setup_apache_encoding # 인코딩 설정 함수 호출
    check_legacy_web_artifacts # 웹 루트 잔여 결과 파일 경고
    execute_security_checks
    convert_results
    restart_apache
}

main
