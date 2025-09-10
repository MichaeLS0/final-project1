# Simple, small Python image
FROM python:3.11-slim

# Avoid writing .pyc files and enable unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install dependencies
WORKDIR /app
COPY app/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source
COPY app/ ./app/

# Expose port and start the app
EXPOSE 5000
CMD ["python", "app/main.py"]
