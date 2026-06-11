# SecureBank AI Security Agent — hardened multi-stage build
# syntax=docker/dockerfile:1.7
FROM python:3.11-slim AS build
ENV PIP_NO_CACHE_DIR=1 PYTHONDONTWRITEBYTECODE=1
WORKDIR /build
RUN apt-get update && apt-get install -y --no-install-recommends gcc libffi-dev && rm -rf /var/lib/apt/lists/*
COPY src/shared/             ./shared/
COPY src/ai-security-agent/  ./ai-security-agent/
RUN pip install --prefix=/install ./shared && \
    pip install --prefix=/install --no-cache-dir \
        fastapi 'uvicorn[standard]' pydantic numpy scikit-learn anthropic prometheus-client && \
    pip install --prefix=/install --no-deps ./ai-security-agent

FROM gcr.io/distroless/python3-debian12:nonroot
ENV PYTHONPATH=/install/lib/python3.11/site-packages:/app
COPY --from=build /install /install
WORKDIR /app
COPY src/ai-security-agent/app/ ./app/
COPY src/shared/securebank_shared /install/lib/python3.11/site-packages/securebank_shared
USER nonroot
EXPOSE 8007
HEALTHCHECK CMD ["python","-c","import urllib.request,sys;urllib.request.urlopen('http://127.0.0.1:8007/health',timeout=2)"]
ENTRYPOINT ["python","-m","uvicorn","app.main:app","--host","0.0.0.0","--port","8007","--no-server-header"]
