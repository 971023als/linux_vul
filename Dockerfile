# Dockerfile for Linux Vulnerability Assessor
# Purpose: Environment consistency for report generation and S3 upload

FROM python:3.9-slim-buster

# 1. Install system dependencies for PDF generation and Korean fonts
RUN apt-get update && apt-get install -y \
    wkhtmltopdf \
    fonts-nanum \
    bash \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Install Python dependencies
# boto3: AWS S3 interaction
# jinja2: HTML template rendering
# pandas: CSV processing
RUN pip install --no-cache-dir \
    boto3 \
    jinja2 \
    pandas \
    pdfkit

# 3. Copy project structure
COPY tools/ ./tools/
COPY templates/ ./templates/
COPY runners/ ./runners/
COPY shell_scirpt/ ./shell_scirpt/
COPY config/ ./config/
COPY main.sh .
COPY SPEC.md .

# 4. Set permissions
RUN chmod +x main.sh && \
    chmod +x tools/*.py 2>/dev/null || true

# 5. Define output volume
VOLUME ["/app/output"]

# 6. Set entry point
ENTRYPOINT ["/bin/bash", "/app/main.sh"]
CMD ["audit", "--profile", "ubuntu"]
