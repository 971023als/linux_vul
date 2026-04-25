#!/usr/bin/env python3
"""
tools/report_generator.py — ISMS-P / 전자금융감독규정 컴플라이언스 HTML 보고서 생성

SPEC: SPEC.md §5 (보고서 매핑)

디버깅: --debug 플래그 또는 DEBUG=1 환경변수
"""

import argparse
import json
import logging
import os
import sys
import time
from datetime import datetime
from pathlib import Path

_log = logging.getLogger("report_generator")

def _setup_logging(debug: bool) -> None:
    level = logging.DEBUG if debug else logging.WARNING
    fmt   = "[%(levelname)s %(asctime)s.%(msecs)03d][report_generator] %(message)s"
    logging.basicConfig(level=level, format=fmt, datefmt="%H:%M:%S", stream=sys.stderr)
    _log.setLevel(level)
    if debug:
        _log.debug("디버그 모드 활성화")


# =============================================================================
# 상태별 색상/아이콘
# =============================================================================
STATUS_STYLE = {
    "PASS":             {"bg": "#e8f5e9", "text": "#2e7d32", "badge": "#4caf50", "icon": "✓"},
    "FAIL":             {"bg": "#ffebee", "text": "#c62828", "badge": "#f44336", "icon": "✗"},
    "NA":               {"bg": "#f5f5f5", "text": "#757575", "badge": "#9e9e9e", "icon": "—"},
    "MANUAL_REVIEW":    {"bg": "#fff8e1", "text": "#f57f17", "badge": "#ffc107", "icon": "?"},
    "EVIDENCE_MISSING": {"bg": "#fce4ec", "text": "#880e4f", "badge": "#e91e63", "icon": "!"},
    "ERROR":            {"bg": "#fff3e0", "text": "#bf360c", "badge": "#ff5722", "icon": "✕"},
    "NOT_IMPLEMENTED":  {"bg": "#ede7f6", "text": "#4527a0", "badge": "#9c27b0", "icon": "○"},
}
DEFAULT_STYLE = {"bg": "#f5f5f5", "text": "#333", "badge": "#9e9e9e", "icon": "·"}

def get_style(status: str) -> dict:
    return STATUS_STYLE.get(status, DEFAULT_STYLE)


# =============================================================================
# HTML 템플릿
# =============================================================================
HTML_HEAD = """<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>주요정보통신기반시설 Linux 취약점 진단 결과보고서</title>
<style>
  :root {{
    --primary:   #1565c0;
    --secondary: #1e88e5;
    --danger:    #f44336;
    --success:   #4caf50;
    --warn:      #ffc107;
    --gray:      #9e9e9e;
    --bg:        #f8f9fa;
  }}
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{
    font-family: 'Segoe UI', 'Malgun Gothic', Arial, sans-serif;
    background: var(--bg);
    color: #333;
    font-size: 14px;
  }}
  header {{
    background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
    color: white;
    padding: 32px 40px;
  }}
  header h1 {{ font-size: 22px; font-weight: 700; margin-bottom: 6px; }}
  header p  {{ font-size: 13px; opacity: 0.85; }}
  .compliance-badges {{
    margin-top: 14px;
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
  }}
  .badge {{
    background: rgba(255,255,255,0.2);
    border: 1px solid rgba(255,255,255,0.4);
    border-radius: 4px;
    padding: 4px 10px;
    font-size: 12px;
    font-weight: 600;
  }}
  .container {{ max-width: 1400px; margin: 0 auto; padding: 24px 40px; }}
  .summary-grid {{
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
    gap: 14px;
    margin-bottom: 28px;
  }}
  .summary-card {{
    background: white;
    border-radius: 8px;
    padding: 16px;
    text-align: center;
    box-shadow: 0 1px 4px rgba(0,0,0,0.08);
    border-top: 4px solid var(--gray);
  }}
  .summary-card .count {{ font-size: 32px; font-weight: 700; margin-bottom: 4px; }}
  .summary-card .label {{ font-size: 12px; color: #666; font-weight: 600; text-transform: uppercase; }}
  .toolbar {{
    background: white;
    border-radius: 8px;
    padding: 14px 18px;
    margin-bottom: 18px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.06);
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    align-items: center;
  }}
  .toolbar span {{ font-size: 13px; color: #666; margin-right: 6px; }}
  .filter-btn {{
    padding: 5px 14px;
    border-radius: 20px;
    border: 1px solid #ddd;
    background: white;
    cursor: pointer;
    font-size: 13px;
    transition: all 0.15s;
  }}
  .filter-btn:hover, .filter-btn.active {{ background: var(--primary); color: white; border-color: var(--primary); }}
  .results-table-wrap {{
    background: white;
    border-radius: 8px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.08);
    overflow: hidden;
  }}
  table {{ width: 100%; border-collapse: collapse; }}
  thead th {{
    background: #1565c0;
    color: white;
    padding: 12px 14px;
    text-align: left;
    font-size: 13px;
    font-weight: 600;
    white-space: nowrap;
  }}
  tbody tr {{ border-bottom: 1px solid #f0f0f0; transition: background 0.1s; }}
  tbody tr:hover {{ background: #f9f9f9; }}
  tbody tr.hidden {{ display: none; }}
  td {{ padding: 11px 14px; vertical-align: top; font-size: 13px; }}
  .status-badge {{
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 3px 10px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 700;
    white-space: nowrap;
  }}
  .detail-text {{
    font-size: 12px;
    color: #555;
    font-family: monospace;
    white-space: pre-wrap;
    word-break: break-all;
    max-height: 80px;
    overflow: auto;
  }}
  .compliance-chip {{
    display: inline-block;
    background: #e3f2fd;
    color: #1565c0;
    border-radius: 3px;
    padding: 2px 7px;
    font-size: 11px;
    margin: 2px 2px 2px 0;
    font-weight: 600;
  }}
  footer {{
    text-align: center;
    padding: 20px;
    color: #aaa;
    font-size: 12px;
    margin-top: 30px;
  }}
  @media print {{
    .toolbar {{ display: none; }}
    body {{ background: white; }}
    .container {{ padding: 10px; }}
  }}
</style>
</head>
<body>
"""

HTML_SCRIPT = """
<script>
function filterTable(status) {
  const rows = document.querySelectorAll('tbody tr');
  const btns = document.querySelectorAll('.filter-btn');
  btns.forEach(b => b.classList.remove('active'));
  event.target.classList.add('active');
  rows.forEach(row => {
    if (status === 'ALL' || row.dataset.status === status) {
      row.classList.remove('hidden');
    } else {
      row.classList.add('hidden');
    }
  });
  const visible = document.querySelectorAll('tbody tr:not(.hidden)').length;
  document.getElementById('visible-count').textContent = visible + ' 항목';
}
</script>
"""


def build_summary_html(summary: dict) -> str:
    _log.debug("build_summary_html: %s", summary)
    color_map = {
        "PASS": "#4caf50", "FAIL": "#f44336", "NA": "#9e9e9e",
        "MANUAL_REVIEW": "#ffc107", "EVIDENCE_MISSING": "#e91e63",
        "ERROR": "#ff5722", "NOT_IMPLEMENTED": "#9c27b0",
    }
    label_map = {
        "PASS": "양호", "FAIL": "취약", "NA": "해당없음",
        "MANUAL_REVIEW": "수동점검", "EVIDENCE_MISSING": "증적없음",
        "ERROR": "오류", "NOT_IMPLEMENTED": "미구현",
    }
    cards = ""
    total = sum(summary.values())
    for status, count in summary.items():
        color = color_map.get(status, "#9e9e9e")
        label = label_map.get(status, status)
        cards += f"""
    <div class="summary-card" style="border-top-color:{color}">
      <div class="count" style="color:{color}">{count}</div>
      <div class="label">{label}</div>
    </div>"""
    cards += f"""
    <div class="summary-card" style="border-top-color:#1565c0">
      <div class="count" style="color:#1565c0">{total}</div>
      <div class="label">전체</div>
    </div>"""
    return f'<div class="summary-grid">{cards}</div>'


def build_filter_toolbar_html(summary: dict) -> str:
    _log.debug("build_filter_toolbar_html: %d 상태", len(summary))
    btns = '<button class="filter-btn active" onclick="filterTable(\'ALL\')">전체</button>\n'
    label_map = {
        "PASS": "양호", "FAIL": "취약", "NA": "해당없음",
        "MANUAL_REVIEW": "수동점검", "EVIDENCE_MISSING": "증적없음",
        "ERROR": "오류", "NOT_IMPLEMENTED": "미구현",
    }
    for status, count in summary.items():
        if count > 0:
            label = label_map.get(status, status)
            btns += f'<button class="filter-btn" onclick="filterTable(\'{status}\')">{label} ({count})</button>\n'
    return f"""
<div class="toolbar">
  <span>필터:</span>
  {btns}
  <span style="margin-left:auto;color:#888" id="visible-count"></span>
</div>"""


def build_results_table_html(results: list) -> str:
    _log.debug("build_results_table_html: %d 행 처리 시작", len(results))
    t0 = time.perf_counter()
    rows = ""
    for i, item in enumerate(results):
        status      = item.get("status", "")
        style       = get_style(status)
        icon        = style["icon"]
        badge_color = style["badge"]
        row_bg      = style["bg"]

        isms_p  = item.get("isms_p", "N/A")
        fin_reg = item.get("financial_reg", "N/A")
        compliance_html = ""
        if isms_p and isms_p != "N/A":
            compliance_html += f'<span class="compliance-chip">ISMS-P {isms_p}</span>'
        if fin_reg and fin_reg != "N/A":
            compliance_html += f'<span class="compliance-chip">{fin_reg}</span>'

        raw = (item.get("detail") or item.get("raw_output") or "").strip()
        if len(raw) > 300:
            raw = raw[:300] + "…"
        raw_escaped = raw.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

        rows += f"""
<tr data-status="{status}" style="background:{row_bg}">
  <td><strong>{item.get('id','')}</strong></td>
  <td>{item.get('category','')}</td>
  <td>
    <span class="status-badge" style="background:{badge_color};color:white">
      {icon} {status}
    </span>
  </td>
  <td>{compliance_html}</td>
  <td><div class="detail-text">{raw_escaped}</div></td>
</tr>"""

        if (i + 1) % 20 == 0:
            _log.debug("  테이블 행 생성: %d/%d", i + 1, len(results))

    elapsed = (time.perf_counter() - t0) * 1000
    _log.debug("build_results_table_html 완료: %d 행  elapsed=%.1fms", len(results), elapsed)
    return f"""
<div class="results-table-wrap">
<table>
  <thead>
    <tr>
      <th style="width:80px">항목 ID</th>
      <th style="width:160px">분류</th>
      <th style="width:150px">진단 결과</th>
      <th style="width:380px">컴플라이언스 매핑</th>
      <th>세부 내용</th>
    </tr>
  </thead>
  <tbody>{rows}
  </tbody>
</table>
</div>"""


# =============================================================================
# 메인 보고서 생성
# =============================================================================
def generate_report(input_path: Path, output_path: Path) -> None:
    _log.debug("generate_report 시작: input=%s  output=%s", input_path, output_path)

    t0   = time.perf_counter()
    data = json.loads(input_path.read_text(encoding="utf-8"))
    _log.debug("JSON 로드: %.1fms", (time.perf_counter()-t0)*1000)

    meta    = data.get("meta", {})
    results = data.get("results", [])
    summary = meta.get("summary", {})

    _log.debug("메타: total=%d  summary=%s", meta.get("total", 0), summary)

    generated_at = meta.get("generated_at", datetime.now().isoformat())
    try:
        dt = datetime.fromisoformat(generated_at)
        generated_str = dt.strftime("%Y년 %m월 %d일 %H:%M:%S")
    except Exception as e:
        _log.debug("날짜 파싱 실패: %s → raw 사용", e)
        generated_str = generated_at

    total      = meta.get("total", len(results))
    pass_count = summary.get("PASS", 0)
    fail_count = summary.get("FAIL", 0)
    pass_rate  = round(pass_count / total * 100, 1) if total else 0

    _log.debug("통계: total=%d  PASS=%d  FAIL=%d  rate=%.1f%%",
               total, pass_count, fail_count, pass_rate)

    _log.debug("HTML 헤더 생성 중...")
    t1  = time.perf_counter()
    html = HTML_HEAD
    html += f"""
<header>
  <h1>주요정보통신기반시설 Linux 취약점 진단 결과보고서</h1>
  <p>생성 일시: {generated_str} &nbsp;|&nbsp; 총 {total}개 항목 &nbsp;|&nbsp; 양호율: {pass_rate}%</p>
  <div class="compliance-badges">
    <span class="badge">전자금융감독규정 §11·13·15 대응</span>
    <span class="badge">ISMS-P 2.4 / 2.6 / 2.10 / 3.2</span>
    <span class="badge">KISA U-01 ~ U-72</span>
    <span class="badge">Audit-Only Mode</span>
  </div>
</header>

<div class="container">
"""
    html += build_summary_html(summary)
    html += build_filter_toolbar_html(summary)
    html += build_results_table_html(results)
    html += f"""
<footer>
  Linux-Vul-Assessor v0.2 &nbsp;|&nbsp; 본 보고서는 인가된 시스템에서의 진단 결과를 기반으로 자동 생성되었습니다.
  &nbsp;|&nbsp; 생성: {generated_str}
</footer>
</div>
"""
    html += HTML_SCRIPT
    html += "\n</body>\n</html>"

    _log.debug("HTML 조립 완료: %d bytes  elapsed=%.1fms",
               len(html), (time.perf_counter()-t1)*1000)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    t2 = time.perf_counter()
    output_path.write_text(html, encoding="utf-8")
    _log.debug("HTML 파일 저장: %s  크기=%d bytes  elapsed=%.1fms",
               output_path, output_path.stat().st_size, (time.perf_counter()-t2)*1000)

    print(f"[Report] Generated: {output_path}")
    print(f"[Report] Summary  : PASS={pass_count}, FAIL={fail_count}, Total={total}, Rate={pass_rate}%")
    _log.debug("generate_report 완료: 총소요=%.0fms", (time.perf_counter()-t0)*1000)


# =============================================================================
# Entrypoint
# =============================================================================
def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate ISMS-P / 전자금융감독규정 compliance HTML report"
    )
    parser.add_argument("--input",  required=True, help="normalized_result.json path")
    parser.add_argument("--output", required=True, help="Output HTML file path")
    parser.add_argument("--debug", action="store_true",
                        default=(os.environ.get("DEBUG", "0") != "0"),
                        help="디버그 로그 출력 (환경변수 DEBUG=1 도 가능)")
    args = parser.parse_args()

    _setup_logging(args.debug)

    input_path  = Path(args.input)
    output_path = Path(args.output)

    _log.debug("main: input=%s  output=%s", input_path, output_path)

    if not input_path.exists():
        print(f"[ERROR] Input file not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    _log.debug("input 크기: %d bytes", input_path.stat().st_size)

    t_start = time.perf_counter()
    generate_report(input_path, output_path)
    _log.debug("main 완료: 총소요=%.0fms", (time.perf_counter() - t_start) * 1000)


if __name__ == "__main__":
    main()
