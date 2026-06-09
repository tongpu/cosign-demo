# Stage 0: Build dependencies in builder
FROM registry.access.redhat.com/hi/python:3.14-builder AS builder
USER 0
WORKDIR /app
COPY pylock.toml .
RUN python3 -m venv /opt/venv && /opt/venv/bin/pip install -r pylock.toml

# Stage 1: Construct deployment image
FROM registry.access.redhat.com/hi/python:3.14

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY app.py wsgi.py .
EXPOSE 8080
STOPSIGNAL SIGINT

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8080", "wsgi:app"]
