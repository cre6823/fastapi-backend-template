# Corrected Dockerfile
# Python 3.10 slim 이미지를 사용합니다.
FROM python:3.10-slim

# 필요한 시스템 패키지와 Oracle Instant Client를 설치합니다.
RUN apt-get update && apt-get install -y libaio1 wget unzip build-essential \
    && rm -rf /var/lib/apt/lists/*

# 작업 디렉토리를 /app으로 설정합니다.
WORKDIR /app

# 모든 프로젝트 파일을 Docker 이미지로 복사합니다.
COPY . .

# Oracle Instant Client를 다운로드하고 설치합니다.
RUN mkdir -p /opt/oracle/instantclient \
    && wget https://download.oracle.com/otn_software/linux/instantclient/2114000/instantclient-basic-linux.x64-21.14.0.0.0dbru.zip \
    && unzip instantclient-basic-linux.x64-21.14.0.0.0dbru.zip -d /opt/oracle/instantclient \
    && rm instantclient-basic-linux.x64-21.14.0.0.0dbru.zip \
    && echo "/opt/oracle/instantclient/instantclient_21_14" > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

# LD_LIBRARY_PATH 환경 변수를 설정하여 Oracle Client 라이브러리를 찾도록 합니다.
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient/instantclient_21_14:$LD_LIBRARY_PATH

# requirements.txt에 있는 Python 라이브러리를 설치합니다.
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션이 실행될 포트를 노출합니다.
EXPOSE 8000

# Gunicorn을 사용하여 FastAPI 애플리케이션을 실행합니다.
CMD ["gunicorn", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000"]
