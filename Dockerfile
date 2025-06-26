# Final Corrected Dockerfile
# Python 3.10 slim 이미지를 사용합니다.
FROM python:3.10-slim

# 필요한 시스템 패키지를 설치합니다.
# build-essential은 Python 패키지 컴파일에 필요합니다.
RUN apt-get update && apt-get install -y libaio1 unzip wget build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set a working directory
WORKDIR /app

# Copy all project files, including the uploaded Oracle Client ZIP
COPY . .

# Unzip the client and set up libraries in a standard location
RUN unzip instantclient-basic-linux.x64-21.14.0.0.0dbru.zip -d /usr/local/lib/ \
    && rm instantclient-basic-linux.x64-21.14.0.0.0dbru.zip

# Set LD_LIBRARY_PATH to the unzipped directory
ENV LD_LIBRARY_PATH=/usr/local/lib/instantclient_21_14:$LD_LIBRARY_PATH

# Update library cache
RUN ldconfig

# Install Python dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8000
EXPOSE 8000

# Command to run the application using Gunicorn
CMD ["gunicorn", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000"]
