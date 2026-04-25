#!/usr/bin/env python3
"""
tools/html_to_pdf.py — HTML → PDF 변환
우선순위: weasyprint → wkhtmltopdf → chromium headless → 수동 안내

디버깅: --debug 플래그 또는 DEBUG=1 환경변수
"""
import argparse
import logging
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

_log = logging.getLogger("html_to_pdf")


def _setup_logging(debug: bool) -> None:
    level = logging.DEBUG if debug else logging.WARNING
    fmt   = "[%(levelname)s %(asctime)s.%(msecs)03d][html_to_pdf] %(message)s"
    logging.basicConfig(level=level, format=fmt, datefmt="%H:%M:%S", stream=sys.stderr)
    _log.setLevel(level)
    if debug:
        _log.debug("디버그 모드 활성화")


def convert_weasyprint(html_path: Path, pdf_path: Path) -> bool:
    """weasyprint 사용 (pip install weasyprint)"""
    _log.debug("weasyprint 시도")
    try:
        import weasyprint  # type: ignore
        _log.debug("weasyprint import 성공: version=%s", getattr(weasyprint, "__version__", "unknown"))
        pdf_path.parent.mkdir(parents=True, exist_ok=True)
        t0 = time.perf_counter()
        weasyprint.HTML(filename=str(html_path)).write_pdf(str(pdf_path))
        elapsed = (time.perf_counter() - t0) * 1000
        pdf_size = pdf_path.stat().st_size if pdf_path.exists() else 0
        _log.debug("weasyprint 완료: elapsed=%.0fms  pdf_size=%d bytes", elapsed, pdf_size)
        return True
    except ImportError:
        _log.debug("weasyprint not installed → 건너뜀")
        return False
    except Exception as e:
        _log.debug("weasyprint 실패: %s", e)
        print(f'[weasyprint] Error: {e}', file=sys.stderr)
        return False


def convert_wkhtmltopdf(html_path: Path, pdf_path: Path) -> bool:
    """wkhtmltopdf CLI 사용"""
    bin_path = shutil.which('wkhtmltopdf')
    _log.debug("wkhtmltopdf which=%s", bin_path or "not found")
    if not bin_path:
        return False
    try:
        pdf_path.parent.mkdir(parents=True, exist_ok=True)
        cmd = [
            'wkhtmltopdf',
            '--encoding', 'utf-8',
            '--page-size', 'A4',
            '--margin-top', '15mm',
            '--margin-bottom', '15mm',
            '--margin-left', '15mm',
            '--margin-right', '15mm',
            str(html_path), str(pdf_path),
        ]
        _log.debug("wkhtmltopdf 실행: %s", " ".join(cmd))
        t0 = time.perf_counter()
        result = subprocess.run(cmd, capture_output=True, text=True)
        elapsed = (time.perf_counter() - t0) * 1000
        _log.debug("wkhtmltopdf exit=%d  elapsed=%.0fms", result.returncode, elapsed)
        if result.stdout:
            _log.debug("wkhtmltopdf stdout: %s", result.stdout[:400])
        if result.stderr:
            _log.debug("wkhtmltopdf stderr: %s", result.stderr[:400])
        if result.returncode == 0:
            pdf_size = pdf_path.stat().st_size if pdf_path.exists() else 0
            _log.debug("wkhtmltopdf 완료: pdf_size=%d bytes", pdf_size)
        return result.returncode == 0
    except Exception as e:
        _log.debug("wkhtmltopdf 예외: %s", e)
        print(f'[wkhtmltopdf] Error: {e}', file=sys.stderr)
        return False


def convert_chromium(html_path: Path, pdf_path: Path) -> bool:
    """Chromium headless 사용"""
    chromium = (
        shutil.which('chromium-browser') or
        shutil.which('chromium') or
        shutil.which('google-chrome') or
        shutil.which('google-chrome-stable')
    )
    _log.debug("chromium which=%s", chromium or "not found")
    if not chromium:
        return False
    try:
        pdf_path.parent.mkdir(parents=True, exist_ok=True)
        cmd = [
            chromium,
            '--headless', '--no-sandbox', '--disable-gpu',
            f'--print-to-pdf={pdf_path}',
            f'file://{html_path.resolve()}',
        ]
        _log.debug("chromium 실행: %s", " ".join(cmd))
        t0 = time.perf_counter()
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        elapsed = (time.perf_counter() - t0) * 1000
        exists  = pdf_path.exists()
        _log.debug("chromium exit=%d  exists=%s  elapsed=%.0fms", result.returncode, exists, elapsed)
        if result.stderr:
            _log.debug("chromium stderr: %s", result.stderr[:400])
        if result.returncode == 0 and exists:
            pdf_size = pdf_path.stat().st_size
            _log.debug("chromium 완료: pdf_size=%d bytes", pdf_size)
        return result.returncode == 0 and exists
    except Exception as e:
        _log.debug("chromium 예외: %s", e)
        print(f'[chromium] Error: {e}', file=sys.stderr)
        return False


def main() -> None:
    parser = argparse.ArgumentParser(description='Convert HTML report to PDF')
    parser.add_argument('--input',  required=True, help='Input HTML file')
    parser.add_argument('--output', required=True, help='Output PDF file')
    parser.add_argument('--debug', action='store_true',
                        default=(os.environ.get("DEBUG", "0") != "0"),
                        help='디버그 로그 출력 (환경변수 DEBUG=1 도 가능)')
    args = parser.parse_args()

    _setup_logging(args.debug)

    html_path = Path(args.input)
    pdf_path  = Path(args.output)

    _log.debug("main: input=%s  output=%s", html_path, pdf_path)

    if not html_path.exists():
        print(f'[ERROR] HTML file not found: {html_path}', file=sys.stderr)
        sys.exit(1)

    html_size = html_path.stat().st_size
    _log.debug("input 크기: %d bytes", html_size)

    print(f'[html_to_pdf] Converting: {html_path} → {pdf_path}')

    t_start = time.perf_counter()

    # 1순위: weasyprint
    if convert_weasyprint(html_path, pdf_path):
        elapsed = (time.perf_counter() - t_start) * 1000
        print(f'[html_to_pdf] Done (weasyprint): {pdf_path}')
        _log.debug("총 소요: %.0fms  engine=weasyprint", elapsed)
        return

    # 2순위: wkhtmltopdf
    if convert_wkhtmltopdf(html_path, pdf_path):
        elapsed = (time.perf_counter() - t_start) * 1000
        print(f'[html_to_pdf] Done (wkhtmltopdf): {pdf_path}')
        _log.debug("총 소요: %.0fms  engine=wkhtmltopdf", elapsed)
        return

    # 3순위: Chromium headless
    if convert_chromium(html_path, pdf_path):
        elapsed = (time.perf_counter() - t_start) * 1000
        print(f'[html_to_pdf] Done (chromium): {pdf_path}')
        _log.debug("총 소요: %.0fms  engine=chromium", elapsed)
        return

    # 모두 실패
    print('[html_to_pdf] No PDF engine found.', file=sys.stderr)
    print('Install one of:', file=sys.stderr)
    print('  pip install weasyprint', file=sys.stderr)
    print('  apt install wkhtmltopdf', file=sys.stderr)
    print('  apt install chromium-browser', file=sys.stderr)
    sys.exit(1)


if __name__ == '__main__':
    main()
