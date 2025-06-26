# Corrected Dockerfile - Use local file
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y libaio1 unzip build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set a working directory
WORKDIR /app

# Copy all project files, including the uploaded Oracle Client ZIP
COPY . .

# Unzip and install Oracle Instant Client from the copied ZIP file
RUN mkdir -p /opt/oracle/instantclient \
    && unzip instantclient-basic-linux.x64-21.14.0.0.0dbru.zip -d /opt/oracle/instantclient \
    && rm instantclient-basic-linux.x64-21.14.0.0.0dbru.zip \
    && echo "/opt/oracle/instantclient/instantclient_21_14" > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

# Set LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient/instantclient_21_14:$LD_LIBRARY_PATH

# Install Python dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8000
EXPOSE 8000

# Command to run the application using Gunicorn
CMD ["gunicorn", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000"]
