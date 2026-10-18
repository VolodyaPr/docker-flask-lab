FROM python:3.11-alpine AS builder

WORKDIR /app

RUN apk add --no-cache \
    build-base \
    libffi-dev \
    musl-dev

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-alpine

ARG LAB_LOGIN
ARG LAB_TOKEN

LABEL org.lab.login="$LAB_LOGIN" \
      org.lab.token="$LAB_TOKEN"

RUN apk add --no-cache dumb-init libstdc++

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY --chown=appuser:appgroup app/ ./app/

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    ROCKET_SIZE=Normal

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

ENTRYPOINT ["dumb-init", "--"]
CMD ["python", "app/app.py"]
