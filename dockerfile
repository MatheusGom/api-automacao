# syntax=docker/dockerfile:1

# === STAGE 1: BUILDER ===
FROM python:3.12-slim AS builder

WORKDIR /app

# Copia e instala as dependências
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    pip wheel -r requirements.txt -w /wheels

# Copia o restante do código da aplicação
COPY . .

# === STAGE 2: RUNTIME ===
FROM python:3.12-slim AS runtime

ENV APP_ENV=production \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copia as dependências pré-compiladas
COPY --from=builder /wheels /wheels
RUN pip install --no-cache /wheels/*

# Copia o código da aplicação
COPY . .

# Porta exposta
EXPOSE 8080

# Healthcheck interno
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/healthz')"

# Usuário não-root por segurança
USER 10001

# Comando de inicialização da API
CMD ["python","-m","uvicorn","src.app:app","--host","0.0.0.0","--port","8080"]
