
# Build Stage
FROM python:3.10-slim as build

WORKDIR /app

# Install build and python dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

################################################################################################

# Image Stage

FROM python:3.10-slim

WORKDIR /app

# Install cron and AWS CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    cron \
    awscli \
 && rm -rf /var/lib/apt/lists/*

# Copy only necessary files from the build stage
COPY --from=build /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# Copy overall application code
COPY .env /app/
COPY main.py /app/
COPY templates/ /app/templates/
COPY model_final/ /app/model_final/
COPY classify_daily.py /app/
COPY cron-script.sh /app/cron-script.sh

####
# Make scripts executable
RUN chmod +x /app/cron-script.sh /app/classify_daily.py

# Create directories
RUN mkdir -m 777 /app/downloads /app/uploads /app/logs /app/archive

# Expose port (Flask)
EXPOSE 5000

# Run application every day
#RUN echo "0 0 * * * /app/cron-script.sh >> /var/log/cron.log 2>&1" | crontab -
#test:
RUN echo "*/5 * * * * /app/cron-script.sh >> /var/log/cron.log 2>&1" | crontab -

# Start application
CMD ["sh", "-c", "cron && python main.py"]

