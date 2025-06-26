# Final Corrected Dockerfile - Use both basic and SDK clients
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y libaio1 unzip wget build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set a working directory
WORKDIR /app

# Copy all project files, including the uploaded Oracle Client ZIPs
COPY . .

# Unzip BOTH basic and SDK clients into the same directory
RUN mkdir -p /usr/local/lib/oracle \
    && unzip instantclient-basic-linux.x64-21.14.0.0.0dbru.zip -d /usr/local/lib/oracle/instantclient \
    && unzip instantclient-sdk-linux.x64-21.14.0.0.0dbru.zip -d /usr/local/lib/oracle/instantclient \
    && rm instantclient-basic-linux.x64-21.14.0.0.0dbru.zip instantclient-sdk-linux.x64-21.14.0.0.0dbru.zip

# Set LD_LIBRARY_PATH and ORACLE_HOME for the compiler
ENV LD_LIBRARY_PATH=/usr/local/lib/oracle/instantclient_21_14:$LD_LIBRARY_PATH
ENV ORACLE_HOME=/usr/local/lib/oracle/instantclient_21_14

# Update library cache
RUN ldconfig

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8000
EXPOSE 8000

# Command to run the application using Gunicorn
CMD ["gunicorn", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000"]
