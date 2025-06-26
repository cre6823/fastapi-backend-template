# Final Corrected Dockerfile (PyPI Installation)
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y libaio1 wget unzip build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set a working directory
WORKDIR /app

# Copy all project files
COPY . .

# Install Python dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8000
EXPOSE 8000

# Command to run the application using Gunicorn
CMD ["gunicorn", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000"]
