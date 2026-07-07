FROM python:3.12-slim

# Python settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install required system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY requirements.txt .

RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN useradd -m appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 8005

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
CMD curl -f http://localhost:8005/ || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8005"]