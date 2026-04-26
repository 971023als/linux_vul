#!/usr/bin/env python3
"""
tools/dbm_html_to_pdf.py
HTML 보고서 → PDF 변환
우선순위: WeasyPrint → Playwright → ReportLab(JSON 기반) → 안내
"""
import os, sys, json, shutil
from datetime import datetime

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HTML_LATEST = os.path.join(PROJECT_DIR, "output", "html", "dbms_report.html")
JSON_LATEST = os.path.join(PROJECT_DIR, "output", "json", "dbms_assessment_result.json")
PDF_DIR     = os.path.join(PROJECT_DIR, "output", "pdf")
LOG_DIR     = os.path.join(PROJECT_DIR, "output", "logs")

STATUS_COLORS = {
    "PASS":              (0.13, 0.65, 0.40),
    "FAIL":              (0.86, 0.20, 0.18),
    "NA":                (0.47, 0.47, 0.47),
    "MANUAL_REVIEW":     (0.96, 0.60, 0.07),
    "EVIDENCE_MISSING":  (0.85, 0.45, 0.07),
    "ERROR":             (0.70, 0.10, 0.10),
    "NOT_IMPLEMENTED":   (0.55, 0.27, 0.07),
}

SEVERITY_COLORS = {
    "CRITICAL": (0.70, 0.10, 0.10),
    "HIGH":     (0.86, 0.20, 0.18),
    "MEDIUM":   (0.96, 0.60, 0.07),
    "LOW":      (0.13, 0.65, 0.40),
    "INFO":     (0.27, 0.53, 0.79),
}


def try_weasyprint(html_path: str, pdf_path: str) -> bool:
    try:
        import weasyprint  # type: ignore
        from weasyprint import HTML  # type: ignore
        base_url = os.path.dirname(html_path)
        HTML(filename=html_path, base_url=base_url).write_pdf(pdf_path)
        return True
    except ImportError:
        return False
    except Exception as e:
        print(f"[dbm_html_to_pdf] WeasyPrint 오류: {e}", file=sys.stderr)
        return False


def try_playwright(html_path: str, pdf_path: str) -> bool:
    try:
        from playwright.sync_api import sync_playwright  # type: ignore
        with sync_playwright() as pw:
            browser = pw.chromium.launch()
            page = browser.new_page()
            page.goto(f"file://{os.path.abspath(html_path)}")
            page.pdf(path=pdf_path, format="A4",
                     print_background=True,
                     margin={"top": "20mm", "bottom": "20mm",
                             "left": "15mm", "right": "15mm"})
            browser.close()
        return True
    except ImportError:
        return False
    except Exception as e:
        print(f"[dbm_html_to_pdf] Playwright 오류: {e}", file=sys.stderr)
        return False


def try_reportlab(json_path: str, pdf_path: str) -> bool:
    """ReportLab으로 JSON 결과를 직접 PDF로 변환 (한글 지원)."""
    try:
        from reportlab.lib.pagesizes import A4
        from reportlab.lib.units import mm
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib import colors
        from reportlab.platypus import (
            SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
            HRFlowable, KeepTogether
        )
        from reportlab.pdfbase import pdfmetrics
        from reportlab.pdfbase.ttfonts import TTFont
    except ImportError:
        return False

    if not os.path.isfile(json_path):
        print(f"[dbm_html_to_pdf] JSON 원본 없음: {json_path}", file=sys.stderr)
        return False

    # ── 한글 폰트 탐색 ──
    FONT_CANDIDATES = [
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/opentype/noto/NotoSansCJKkr-Regular.otf",
        "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/truetype/noto/NotoSansCJKkr-Regular.ttf",
        "/usr/share/fonts/noto-cjk/NotoSansCJK-Regular.ttc",
        "/system/fonts/NotoSansCJK-Regular.ttc",
    ]
    FONT_NAME = "Helvetica"  # 폴백
    for fpath in FONT_CANDIDATES:
        if os.path.isfile(fpath):
            try:
                pdfmetrics.registerFont(TTFont("NotoSansKR", fpath))
                FONT_NAME = "NotoSansKR"
                break
            except Exception:
                continue

    try:
        with open(json_path, encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        print(f"[dbm_html_to_pdf] JSON 파싱 오류: {e}", file=sys.stderr)
        return False

    target  = data.get("target", {})
    tool    = data.get("tool", {})
    policy  = data.get("policy", {})
    summary = data.get("summary", {})
    results = data.get("results", [])

    doc = SimpleDocTemplate(
        pdf_path,
        pagesize=A4,
        leftMargin=20 * mm, rightMargin=20 * mm,
        topMargin=20 * mm, bottomMargin=20 * mm,
        title="DBMS 취약점 진단 보고서",
    )

    styles = getSampleStyleSheet()
    h1 = ParagraphStyle("h1", fontName=FONT_NAME, fontSize=18, spaceAfter=6,
                         textColor=colors.HexColor("#1a237e"), leading=22)
    h2 = ParagraphStyle("h2", fontName=FONT_NAME, fontSize=13, spaceAfter=4,
                         textColor=colors.HexColor("#283593"), leading=16)
    body = ParagraphStyle("body", fontName=FONT_NAME, fontSize=9, leading=13)
    small = ParagraphStyle("small", fontName=FONT_NAME, fontSize=8, leading=11,
                           textColor=colors.HexColor("#555555"))

    story = []

    # ── 표지 ──
    story.append(Paragraph("DBMS 취약점 진단 보고서", h1))
    story.append(HRFlowable(width="100%", thickness=2,
                             color=colors.HexColor("#1a237e")))
    story.append(Spacer(1, 6 * mm))

    exec_ts  = data.get("generated_at", "")
    profile  = target.get("profile", "")
    version  = tool.get("version", "0.1")
    dry_run  = policy.get("dry_run", False)
    story.append(Paragraph(f"프로파일: <b>{profile}</b>", body))
    story.append(Paragraph(f"진단 일시: {exec_ts}", body))
    story.append(Paragraph(f"버전: {version}  |  dry_run: {dry_run}", body))
    story.append(Spacer(1, 8 * mm))

    # ── 전체 결과 요약 ──
    story.append(Paragraph("전체 결과 요약", h2))

    STATUS_ORDER = ["PASS", "FAIL", "NA", "MANUAL_REVIEW",
                    "EVIDENCE_MISSING", "ERROR", "NOT_IMPLEMENTED"]
    total = summary.get("total", 0)
    sum_rows = [["상태", "건수", "비율"]]
    for s in STATUS_ORDER:
        cnt = summary.get(s.lower(), summary.get(s, 0))
        pct = f"{100 * cnt / total:.1f}%" if total > 0 else "0%"
        sum_rows.append([s, str(cnt), pct])
    sum_rows.append(["합계", str(total), "100%"])

    def _rgb(r, g, b):
        return colors.Color(r, g, b)

    sum_style = TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#283593")),
        ("TEXTCOLOR",  (0, 0), (-1, 0), colors.white),
        ("FONTNAME",   (0, 0), (-1, -1), FONT_NAME),
        ("FONTSIZE",   (0, 0), (-1, -1), 9),
        ("ROWBACKGROUNDS", (0, 1), (-1, -2),
         [colors.HexColor("#f5f5f5"), colors.white]),
        ("BACKGROUND", (0, -1), (-1, -1), colors.HexColor("#e8eaf6")),
        ("GRID",       (0, 0), (-1, -1), 0.5, colors.HexColor("#cccccc")),
        ("ALIGN",      (1, 0), (-1, -1), "CENTER"),
        ("TOPPADDING",  (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ])
    # 상태별 색상
    for i, s in enumerate(STATUS_ORDER, start=1):
        rgb = STATUS_COLORS.get(s, (0.3, 0.3, 0.3))
        sum_style.add("TEXTCOLOR", (0, i), (0, i), _rgb(*rgb))

    sum_table = Table(sum_rows, colWidths=[60 * mm, 30 * mm, 30 * mm])
    sum_table.setStyle(sum_style)
    story.append(sum_table)
    story.append(Spacer(1, 8 * mm))

    # ── 항목별 상세 결과 ──
    story.append(Paragraph("항목별 상세 결과", h2))
    story.append(Spacer(1, 3 * mm))

    detail_header = ["ID", "항목명", "상태", "심각도", "REASON"]
    detail_rows = [detail_header]

    sort_key = {s: i for i, s in enumerate(
        ["FAIL", "ERROR", "EVIDENCE_MISSING", "MANUAL_REVIEW",
         "NOT_IMPLEMENTED", "NA", "PASS"]
    )}
    sorted_results = sorted(results,
                             key=lambda r: sort_key.get(r.get("status", ""), 99))

    for r in sorted_results:
        rid    = r.get("id", "")
        title  = r.get("title", "")
        status = r.get("status", "")
        sev    = r.get("severity_label", "")
        reason = r.get("reason", "")
        if len(reason) > 80:
            reason = reason[:77] + "..."
        detail_rows.append([rid, title, status, sev, reason])

    col_w = [18 * mm, 52 * mm, 28 * mm, 22 * mm, 50 * mm]
    det_style = TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#283593")),
        ("TEXTCOLOR",  (0, 0), (-1, 0), colors.white),
        ("FONTNAME",   (0, 0), (-1, -1), FONT_NAME),
        ("FONTSIZE",   (0, 0), (-1, -1), 7),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1),
         [colors.HexColor("#f9f9f9"), colors.white]),
        ("GRID",       (0, 0), (-1, -1), 0.4, colors.HexColor("#dddddd")),
        ("ALIGN",      (2, 0), (3, -1), "CENTER"),
        ("TOPPADDING",  (0, 0), (-1, -1), 3),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
        ("WORDWRAP",   (1, 1), (1, -1), True),
        ("WORDWRAP",   (4, 1), (4, -1), True),
    ])
    for i, r in enumerate(sorted_results, start=1):
        status = r.get("status", "")
        rgb = STATUS_COLORS.get(status, (0.3, 0.3, 0.3))
        det_style.add("TEXTCOLOR", (2, i), (2, i), _rgb(*rgb))
        sev = r.get("severity_label", "")
        srgb = SEVERITY_COLORS.get(sev, (0.3, 0.3, 0.3))
        det_style.add("TEXTCOLOR", (3, i), (3, i), _rgb(*srgb))

    det_table = Table(detail_rows, colWidths=col_w, repeatRows=1)
    det_table.setStyle(det_style)
    story.append(det_table)
    story.append(Spacer(1, 6 * mm))

    # ── 취약 항목 상세 ──
    fail_items = [r for r in sorted_results if r.get("status") == "FAIL"]
    if fail_items:
        story.append(Paragraph("취약 항목 상세", h2))
        for r in fail_items:
            block = []
            block.append(Paragraph(
                f"<b>{r.get('check_id','')} — {r.get('title','')}</b>", body))
            block.append(Paragraph(
                f"심각도: {r.get('severity_label','')}  |  "
                f"위험도: {r.get('risk_level','')}",
                small))
            block.append(Paragraph(
                f"Reason: {r.get('reason','')}", small))
            block.append(Paragraph(
                f"조치 권고: {r.get('recommendation','')}", small))
            block.append(HRFlowable(width="100%", thickness=0.5,
                                     color=colors.HexColor("#cccccc"),
                                     spaceAfter=4))
            story.append(KeepTogether(block))

    # ── 푸터 ──
    story.append(Spacer(1, 10 * mm))
    story.append(HRFlowable(width="100%", thickness=1,
                             color=colors.HexColor("#aaaaaa")))
    story.append(Paragraph(
        f"생성: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  |  "
        "linux_vul DBMS 취약점 진단 자동화",
        small))

    doc.build(story)
    return True


def main():
    os.makedirs(PDF_DIR, exist_ok=True)
    os.makedirs(LOG_DIR, exist_ok=True)

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    ts_path     = os.path.join(PDF_DIR, f"dbms_report_{ts}.pdf")
    latest_path = os.path.join(PDF_DIR, "dbms_report.pdf")
    log_path    = os.path.join(LOG_DIR, f"dbm_html_to_pdf_{ts}.log")

    html_ok = os.path.isfile(HTML_LATEST)

    # WeasyPrint 시도 (HTML 기반)
    if html_ok and try_weasyprint(HTML_LATEST, ts_path):
        shutil.copy(ts_path, latest_path)
        print(f"[dbm_html_to_pdf] ✅ WeasyPrint PDF 저장: {ts_path}")
        print(f"[dbm_html_to_pdf] latest: {latest_path}")
        return

    # Playwright 시도 (HTML 기반)
    if html_ok and try_playwright(HTML_LATEST, ts_path):
        shutil.copy(ts_path, latest_path)
        print(f"[dbm_html_to_pdf] ✅ Playwright PDF 저장: {ts_path}")
        print(f"[dbm_html_to_pdf] latest: {latest_path}")
        return

    # ReportLab 시도 (JSON 기반 — 네트워크 없이 동작)
    print("[dbm_html_to_pdf] WeasyPrint/Playwright 없음 → ReportLab 폴백 시도")
    if try_reportlab(JSON_LATEST, ts_path):
        shutil.copy(ts_path, latest_path)
        print(f"[dbm_html_to_pdf] ✅ ReportLab PDF 저장: {ts_path}")
        print(f"[dbm_html_to_pdf] latest: {latest_path}")
        with open(log_path, "w") as f:
            f.write(f"ReportLab PDF 생성 성공: {ts_path}\n")
        return

    # 모두 없음 → 안내
    msg = """[dbm_html_to_pdf] PDF 생성 도구를 찾을 수 없습니다.

다음 중 하나를 설치하세요:
  1) WeasyPrint (권장, 네트워크 필요):
       pip install weasyprint
       apt-get install fonts-noto-cjk
  2) Playwright (네트워크 필요):
       pip install playwright
       playwright install chromium
  3) ReportLab (이미 시도, 오류 발생 시 재설치):
       pip install reportlab

HTML 보고서는 이미 생성되어 있습니다:
  """ + HTML_LATEST + """

JSON 결과 파일:
  """ + JSON_LATEST

    print(msg)
    with open(log_path, "w") as f:
        f.write(msg + "\n")
    sys.exit(0)


if __name__ == "__main__":
    main()
