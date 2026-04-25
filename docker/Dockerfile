# docker/Dockerfile
FROM python:3.9-slim-buster

# 1. 시스템 의존성 설치 (Pandoc, 한글 폰트, WeasyPrint 필요 라이브러리)
RUN apt-get update && apt-get install -y \
    pandoc \
    fonts-nanum \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libffi-dev \
    shared-mime-info \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Python 패키지 설치
RUN pip install --no-cache-dir weasyprint

# 3. 작업 디렉터리 설정
WORKDIR /report

# 4. 변환 스크립트 복사
COPY convert.sh /usr/local/bin/convert-report
RUN chmod +x /usr/local/bin/convert-report

# 컨테이너 실행 시 변환 스크립트 대기
ENTRYPOINT ["convert-report"]
