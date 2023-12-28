FROM python:3.10-slim

WORKDIR /app

# Install cron
RUN apt-get update && apt-get install -y cron

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy overall application code
COPY .env /app/
COPY main.py /app/
COPY templates/ /app/templates/
COPY model_final/ /app/model_final/

####
COPY classify_daily.py /app/
RUN chmod 777 /app/classify_daily.py 
RUN chmod +x /app/classify_daily.py
####

COPY cron-script.sh /app/cron-script.sh
RUN chmod +x /app/cron-script.sh

RUN mkdir -m 777 /app/downloads
RUN mkdir -m 777 /app/uploads
RUN mkdir -m 777 /app/logs
RUN mkdir -m 777 /app/archive

# Expose port (Flask):
EXPOSE 5000

# Run application every day:
RUN echo "0 0 * * * /app/cron-script.sh >> /var/log/cron.log 2>&1" | crontab -
# : * every day of month, * every month, * every day of week

# Start application
CMD ["sh", "-c", "cron && python main.py"]
