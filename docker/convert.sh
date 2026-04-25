#!/bin/bash
# docker/convert.sh
# -----------------------------------------------------------------------------
# Markdown 리포트를 HTML 및 PDF로 변환하는 스크립트
# -----------------------------------------------------------------------------

INPUT_FILE=$1
OUTPUT_NAME=$(basename "$INPUT_FILE" .md)

if [ ! -f "$INPUT_FILE" ]; then
    echo "[Error] 입력 파일을 찾을 수 없습니다: $INPUT_FILE"
    exit 1
fi

echo "[Info] 리포트 변환 시작: $INPUT_FILE"

# 1. Markdown -> HTML 변환 (Pandoc)
# 스타일 적용을 위해 간단한 CSS 포함 가능
pandoc "$INPUT_FILE" -o "${OUTPUT_NAME}.html" \
    --metadata title="보안 진단 리포트" \
    -s --self-contained

# 2. HTML -> PDF 변환 (WeasyPrint)
# 한국어 폰트(나눔고딕) 강제 적용을 위한 CSS 인라인 추가
python3 -m weasyprint "${OUTPUT_NAME}.html" "${OUTPUT_NAME}.pdf"

echo "[Success] 변환 완료:"
echo " - HTML: ${OUTPUT_NAME}.html"
echo " - PDF : ${OUTPUT_NAME}.pdf"
