# Use slim Python image
FROM python:3.12-slim

# Set envs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=app.settings

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m appuser

# Workdir
WORKDIR /app

# Install deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Change owner
RUN chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8000

# Start server
ENTRYPOINT ["sh", "/app/startapp.sh"]
