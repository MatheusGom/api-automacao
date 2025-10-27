from fastapi import FastAPI, Request
import os
import time  # <-- CORREÇÃO 1: Importações em linhas separadas

app = FastAPI(title=os.getenv("APP_NAME", "{{PROJECT_NAME}}"))


@app.middleware("http")
async def add_timing(request: Request, call_next):
    start = time.time()  # <-- CORREÇÃO 2: Linhas separadas
    resp = await call_next(request)
    resp.headers["X-Request-Duration"] = str(round((time.time() - start) * 1000, 2))
    return resp


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/ping")
def ping():
    pong_value = os.getenv("PONG_VALUE", "default_pong")
    return {"pong": pong_value}
