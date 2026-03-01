from fastapi import FastAPI
from .api import users, auth

app = FastAPI(title="My Server API", description="API для мобильного приложения")

app.include_router(users.router)
app.include_router(auth.router)

@app.get("/")
def root():
    return {"message": "Сервер работает! Документация: /docs"}
