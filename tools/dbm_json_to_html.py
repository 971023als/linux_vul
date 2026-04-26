#!/usr/bin/env python3
"""
tools/dbm_json_to_html.py
DBMS 진단 결과 JSON → HTML 보고서 (15개 섹션)
Jinja2 없으면 내장 HTML 생성
"""
import json, os, sys, shutil, html
from datetime import datetime

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSON_LATEST = os.path.join(PROJECT_DIR, "output", "json", "dbms_assessment_result.json")
HTML_DIR    = os.path.join(PROJECT_DIR, "output", "html")
CSS_FILE    = os.path.join(PROJECT_DIR, "templates", "dbm_style.css")

STATUS_ORDER = ["FAIL", "ERROR", "EVIDENCE_MISSING", "MANUAL_REVIEW", "NOT_IMPLEMENTED", "NA", "PASS"]


def load_json(path: str) -> dict:
    if not os.path.isfile(path):
        return {}
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def load_css() -> str:
    if os.path.isfile(CSS_FILE):
        with open(CSS_FILE, encoding="utf-8") as f:
            return f.read()
    return ""


def esc(v) -> str:
    return html.escape(str(v) if v is not None else "")


def badge(status: str) -> str:
    return f'<span class="badge badge-{esc(status)}">{esc(status)}</span>'


def sev_badge(label: str) -> str:
    return f'<span class="badge sev-{esc(label)}">{esc(label)}</span>'


def results_by_status(results: list, statuses: list) -> list:
    return [r for r in results if r.get("status") in statuses]


def results_table(results: list, columns=None) -> str:
    if not results:
        return "<p><em>해당 항목 없음</em></p>"
    if columns is None:
        columns = ["id", "title", "profile", "severity_label", "status", "reason"]
    col_labels = {
        "id": "ID", "source_id": "원본ID", "title": "항목명", "profile": "Profile",
        "risk_level": "위험도", "severity_label": "등급", "status": "결과",
        "reason": "판단 근거", "description": "설명", "recommendation": "대응방안",
        "script_path": "스크립트", "error_message": "오류"
    }
    rows = []
    for r in results:
        row_class = f"row-{r.get('status','')}"
        cells = []
        for col in columns:
            val = r.get(col, "")
            if col == "status":
                cells.append(f"<td>{badge(val)}</td>")
            elif col == "severity_label":
                cells.append(f"<td>{sev_badge(val)}</td>")
            elif col == "script_path":
                v = r.get("script", {}).get("path", "")
                cells.append(f"<td><code>{esc(v)}</code></td>")
            else:
                cells.append(f"<td>{esc(val)}</td>")
        rows.append(f'<tr class="{row_class}">{"".join(cells)}</tr>')
    header = "".join(f"<th>{col_labels.get(c, c)}</th>" for c in columns)
    return f"""<table>
<thead><tr>{header}</tr></thead>
<tbody>{"".join(rows)}</tbody>
</table>"""


def generate_html(data: dict) -> str:
    css = load_css()
    summary = data.get("summary", {})
    target  = data.get("target", {})
    policy  = data.get("policy", {})
    tool    = data.get("tool", {})
    results = sorted(
        data.get("results", []),
        key=lambda r: (STATUS_ORDER.index(r.get("status", "NA")) if r.get("status") in STATUS_ORDER else 99,
                       r.get("id", ""))
    )
    gen_at  = data.get("generated_at", "")
    aid     = data.get("assessment_id", "")

    fails     = results_by_status(results, ["FAIL"])
    errors    = results_by_status(results, ["ERROR"])
    missing   = results_by_status(results, ["EVIDENCE_MISSING"])
    manuals   = results_by_status(results, ["MANUAL_REVIEW"])
    not_impl  = results_by_status(results, ["NOT_IMPLEMENTED"])
    nas       = results_by_status(results, ["NA"])
    passes    = results_by_status(results, ["PASS"])

    # Priority: FAIL(HIGH/CRITICAL) first
    priority = sorted(fails + errors + missing,
                      key=lambda r: (-(r.get("risk_level", 0)), r.get("id", "")))

    def section(num, sid, title, content):
        return f"""
<section id="sec{num}">
  <h2>{num}. {esc(title)}</h2>
  {content}
</section>"""

    # ── 섹션 1: 진단 개요
    s1 = f"""<table>
<thead><tr><th>항목</th><th>내용</th></tr></thead>
<tbody>
<tr><td>진단 ID</td><td>{esc(aid)}</td></tr>
<tr><td>도구명</td><td>{esc(tool.get('name',''))} v{esc(tool.get('version',''))}</td></tr>
<tr><td>기준 파일</td><td>{esc(tool.get('baseline_file',''))}</td></tr>
<tr><td>생성 일시</td><td>{esc(gen_at)}</td></tr>
</tbody></table>"""

    # ── 섹션 2: 진단 대상
    s2 = f"""<table>
<thead><tr><th>항목</th><th>내용</th></tr></thead>
<tbody>
<tr><td>DBMS Profile</td><td>{esc(target.get('profile',''))}</td></tr>
<tr><td>범위</td><td>{esc(target.get('scope',''))}</td></tr>
<tr><td>자산명</td><td>{esc(target.get('asset_name',''))}</td></tr>
<tr><td>IP</td><td>{esc(target.get('ip',''))}</td></tr>
</tbody></table>"""

    # ── 섹션 3: 적용 기준
    s3 = f"""<p>전자금융업 DBMS 취약점 진단 기준 ({esc(tool.get('baseline_file',''))}) 기반
DBM-001 ~ DBM-031 (총 31개 항목) 적용</p>"""

    # ── 섹션 4: 실행 정책
    policy_rows = "".join(
        f"<tr><td>{esc(k)}</td><td>{esc(v)}</td></tr>"
        for k, v in policy.items()
    )
    s4 = f"""<div class="policy-box">
<strong>⚠ Phase 0 정책:</strong> 실제 DB 접속 금지 · 로컬 증적 파일만 분석 · 조치 기능 미구현
</div>
<table><thead><tr><th>정책</th><th>값</th></tr></thead><tbody>{policy_rows}</tbody></table>"""

    # ── 섹션 5: 전체 결과 요약
    cards = [
        ("total", "전체", summary.get("total", 0)),
        ("pass",  "PASS", summary.get("pass", 0)),
        ("fail",  "FAIL", summary.get("fail", 0)),
        ("na",    "NA",   summary.get("na", 0)),
        ("manual","MANUAL_REVIEW", summary.get("manual_review", 0)),
        ("missing","EVIDENCE_MISSING", summary.get("evidence_missing", 0)),
        ("error", "ERROR", summary.get("error", 0)),
        ("notimpl","NOT_IMPLEMENTED", summary.get("not_implemented", 0)),
    ]
    card_html = "".join(
        f'<div class="card {cls}"><div class="num">{n}</div><div class="lbl">{lbl}</div></div>'
        for cls, lbl, n in cards
    )
    s5 = f'<div class="summary-grid">{card_html}</div>'

    # ── 섹션 6: DBMS 유형별 결과 (profile은 단일)
    s6 = f"<p>대상 Profile: <strong>{esc(target.get('profile',''))}</strong> · 총 {esc(summary.get('total',0))}개 점검</p>"

    # ── 섹션 7: 위험도별 결과
    by_sev = {}
    for r in results:
        s = r.get("severity_label", "UNKNOWN")
        by_sev.setdefault(s, {"PASS":0,"FAIL":0,"OTHER":0})
        st = r.get("status","")
        if st == "PASS": by_sev[s]["PASS"] += 1
        elif st == "FAIL": by_sev[s]["FAIL"] += 1
        else: by_sev[s]["OTHER"] += 1
    sev_rows = "".join(
        f"<tr><td>{sev_badge(s)}</td><td>{v['PASS']}</td><td>{v['FAIL']}</td><td>{v['OTHER']}</td></tr>"
        for s, v in sorted(by_sev.items(), key=lambda x: ["CRITICAL","HIGH","MEDIUM","LOW","INFO"].index(x[0]) if x[0] in ["CRITICAL","HIGH","MEDIUM","LOW","INFO"] else 9)
    )
    s7 = f"""<table>
<thead><tr><th>등급</th><th>PASS</th><th>FAIL</th><th>기타</th></tr></thead>
<tbody>{sev_rows}</tbody></table>"""

    # ── 섹션 8: 항목별 상세 결과
    s8 = results_table(results, ["id", "title", "severity_label", "status", "reason"])

    # ── 섹션 9: 취약 항목
    s9 = results_table(fails, ["id", "title", "severity_label", "status", "reason", "recommendation"]) if fails else "<p><em>취약 항목 없음</em></p>"

    # ── 섹션 10: 오류 항목
    s10 = results_table(errors, ["id", "title", "status", "reason"]) if errors else "<p><em>오류 항목 없음</em></p>"

    # ── 섹션 11: 미구현 항목
    s11 = results_table(not_impl, ["id", "title", "status", "reason"]) if not_impl else "<p><em>미구현 항목 없음</em></p>"

    # ── 섹션 12: 수동 검토 필요 항목
    s12 = results_table(manuals, ["id", "title", "severity_label", "status", "reason"]) if manuals else "<p><em>수동 검토 항목 없음</em></p>"

    # ── 섹션 13: 증적 부족 항목
    s13 = results_table(missing, ["id", "title", "severity_label", "status", "reason"]) if missing else "<p><em>증적 부족 항목 없음</em></p>"

    # ── 섹션 14: 증적 목록
    ev_rows = []
    for r in results:
        for ev in r.get("evidence", []):
            ev_rows.append(f"<tr><td>{esc(r.get('id',''))}</td><td>{esc(r.get('profile',''))}</td><td>{esc(ev)}</td></tr>")
    s14 = (f"""<table><thead><tr><th>ID</th><th>Profile</th><th>증적</th></tr></thead>
<tbody>{"".join(ev_rows)}</tbody></table>""" if ev_rows else "<p><em>증적 파일 없음</em></p>")

    # ── 섹션 15: 조치 우선순위
    pri_rows = "".join(
        f"<tr><td>{i+1}</td><td>{esc(r.get('id',''))}</td><td>{esc(r.get('title',''))}</td>"
        f"<td>{sev_badge(r.get('severity_label',''))}</td>"
        f"<td>{badge(r.get('status',''))}</td>"
        f"<td>{esc(r.get('recommendation',''))}</td></tr>"
        for i, r in enumerate(priority)
    )
    s15 = (f"""<table><thead><tr><th>순위</th><th>ID</th><th>항목명</th><th>등급</th><th>결과</th><th>대응방안</th></tr></thead>
<tbody>{pri_rows}</tbody></table>""" if priority else "<p><em>즉시 조치 필요 항목 없음</em></p>")

    # TOC
    toc_items = [
        (1, "진단 개요"), (2, "진단 대상"), (3, "적용 기준"), (4, "실행 정책"),
        (5, "전체 결과 요약"), (6, "DBMS 유형별 결과"), (7, "위험도별 결과"),
        (8, "항목별 상세 결과"), (9, "취약 항목"), (10, "오류 항목"),
        (11, "미구현 항목"), (12, "수동 검토 필요 항목"), (13, "증적 부족 항목"),
        (14, "증적 목록"), (15, "조치 우선순위"),
    ]
    toc_html = "".join(f'<li><a href="#sec{n}">{n}. {esc(t)}</a></li>' for n, t in toc_items)

    sections_html = "".join([
        section(1, "sec1", "진단 개요", s1),
        section(2, "sec2", "진단 대상", s2),
        section(3, "sec3", "적용 기준", s3),
        section(4, "sec4", "실행 정책", s4),
        section(5, "sec5", "전체 결과 요약", s5),
        section(6, "sec6", "DBMS 유형별 결과", s6),
        section(7, "sec7", "위험도별 결과", s7),
        section(8, "sec8", "항목별 상세 결과", s8),
        section(9, "sec9", "취약 항목", s9),
        section(10, "sec10", "오류 항목", s10),
        section(11, "sec11", "미구현 항목", s11),
        section(12, "sec12", "수동 검토 필요 항목", s12),
        section(13, "sec13", "증적 부족 항목", s13),
        section(14, "sec14", "증적 목록", s14),
        section(15, "sec15", "조치 우선순위", s15),
    ])

    return f"""<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>DBMS 취약점 진단 보고서 – {esc(target.get('profile',''))}</title>
<style>{css}</style>
</head>
<body>
<div class="report-header">
  <h1>전자금융업 DBMS 취약점 진단 보고서</h1>
  <div class="meta">
    Profile: <strong>{esc(target.get('profile',''))}</strong> &nbsp;|&nbsp;
    생성일시: {esc(gen_at)} &nbsp;|&nbsp;
    진단 ID: {esc(aid)}
  </div>
</div>

<nav class="toc">
  <h3>목차</h3>
  <ol>{toc_html}</ol>
</nav>

{sections_html}

<footer style="text-align:center;padding:20px;color:#999;font-size:.8rem;">
  DBMS 취약점 진단 보고서 · 자동 생성 · Phase 0 (read-only evidence mode)
</footer>
</body>
</html>"""


def main():
    os.makedirs(HTML_DIR, exist_ok=True)
    data = load_json(JSON_LATEST)
    if not data:
        print(f"[dbm_json_to_html] JSON 없음: {JSON_LATEST} — 빈 보고서 생성")
        data = {"assessment_id": "N/A", "tool": {}, "target": {}, "policy": {},
                "summary": {}, "results": [], "generated_at": ""}

    html_content = generate_html(data)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    ts_path     = os.path.join(HTML_DIR, f"dbms_report_{ts}.html")
    latest_path = os.path.join(HTML_DIR, "dbms_report.html")

    with open(ts_path, "w", encoding="utf-8") as f:
        f.write(html_content)
    shutil.copy(ts_path, latest_path)
    print(f"[dbm_json_to_html] HTML 저장: {ts_path}")
    print(f"[dbm_json_to_html] latest:  {latest_path}")


if __name__ == "__main__":
    main()
