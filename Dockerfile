# Dockerfile
# Python 3.10 slim 이미지를 사용합니다.
FROM python:3.10-slim

# OCI Instant Client를 설치하기 위한 의존성 패키지를 설치합니다.
RUN apt-get update && apt-get install -y libaio1 wget unzip

# OCI Instant Client 설치 경로를 설정합니다.
ENV LD_LIBRARY_PATH=/usr/lib/oracle/21/client64

# /app 디렉토리를 작업 공간으로 설정합니다.
WORKDIR /app

# requirements.txt 파일을 복사하고 의존성을 설치합니다.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# OCI Instant Client를 다운로드하고 설치합니다.
# 21.14 버전 다운로드 URL (Oracle 공식 URL)
RUN mkdir -p /usr/lib/oracle/21/client64 \
    && cd /tmp \
    && wget https://download.oracle.com/otn_software/linux/instantclient/2114000/instantclient-basic-linux.x64-21.14.0.0.0dbru.zip \
    && unzip instantclient-basic-linux.x64-21.14.0.0.0dbru.zip \
    && mv instantclient_21_14/* /usr/lib/oracle/21/client64/ \
    && rm instantclient-basic-linux.x64-21.14.0.0.0dbru.zip \
    && echo "/usr/lib/oracle/21/client64" > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

# 모든 소스 코드를 Docker 이미지로 복사합니다.
COPY . .

# Gunicorn을 사용하여 FastAPI 애플리케이션을 실행합니다.
CMD ["gunicorn", "main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
