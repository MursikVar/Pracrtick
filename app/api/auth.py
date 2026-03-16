from fastapi import APIRouter, Depends, HTTPException, status, Response
from sqlalchemy.orm import Session
from .. import schemas, crud
from ..database import SessionLocal
from ..core.security import create_access_token, create_refresh_token, decode_token
from datetime import timedelta
from ..core.deps import get_db, security, get_current_user
from ..models import Student
import os
from google.oauth2 import id_token
from google.auth.transport import requests
from ..services.email_service import EmailService

router = APIRouter(prefix="/api/v1/auth", tags=["authentication"])

email_service = EmailService()

@router.post(
    "/send-verification",
    summary="Отправить код подтверждения на email",
    description="""
        Этот эндпоинт позволяет отправить код подтверждения на указанный email.
        Клиент отправляет свой логин (email) и код (например, 123456), 
        сервер пересылает это письмо через настроенный SMTP-сервер.
    """,
    response_description="Письмо успешно отправлено",
    responses={
        500: {
            "description": "Ошибка при отправке письма",
            "content": {
                "application/json": {
                    "example": {"detail": "Failed to send verification email. Check server logs."}
                }
            }
        },
        422: {
            "description": "Ошибка валидации (неверный формат email или код)",
            "content": {
                "application/json": {
                    "example": {
                        "detail": [
                            {
                                "loc": ["body", "code"],
                                "msg": "ensure this value has at least 4 characters",
                                "type": "value_error.any_str.min_length"
                            }
                        ]
                    }
                }
            }
        }
    }
)
def send_verification_email(request: schemas.VerificationEmailRequest):
    """
    Отправляет код подтверждения на указанный email.
    """
    # Логируем попытку отправки (опционально)
    print(f"Attempting to send verification code to {request.login}")
    
    # Вызываем сервис для отправки
    success = email_service.send_verification_email(request.login, request.code)
    
    if not success:
        # Если отправка не удалась, возвращаем ошибку 500
        raise HTTPException(
            status_code=500,
            detail="Failed to send verification email. Check server logs."
        )
    
    # При успехе возвращаем подтверждение
    return Response(status_code = 200)

@router.post(
    "/register",
    response_model=schemas.TokenResponse,
    summary="Регистрация нового пользователя",
    description="Создаёт нового пользователя и возвращает пару токенов (access и refresh).",
    responses={
        400: {
            "description": "Логин уже занят",
            "content": {
                "application/json": {
                    "example": {"detail": "Login already registered"}
                }
            }
        },
        422: {
            "description": "Ошибка валидации (например, слишком короткий пароль)",
            "content": {
                "application/json": {
                    "example": {
                        "detail": [
                            {
                                "loc": ["body", "password"],
                                "msg": "ensure this value has at least 6 characters",
                                "type": "value_error.any_str.min_length"
                            }
                        ]
                    }
                }
            }
        }
    }
)

def register(user_data: schemas.UserRegister, db: Session = Depends(get_db)):
    # Проверяем, не занят ли логин
    if crud.get_user_by_login(db, user_data.login):
        raise HTTPException(status_code=400, detail="Login already registered")
    # Создаём пользователя
    user = crud.create_user(db, user_data)
    # Генерируем токены
    access_token = create_access_token({"sub": user.login})
    refresh_token = create_refresh_token({"sub": user.login})
    # Сохраняем refresh_token в БД
    crud.save_refresh_token(db, user.login, refresh_token)
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post(
    "/login",
    response_model=schemas.TokenResponse,
    summary="Вход в систему",
    description="Проверяет логин и пароль, возвращает пару токенов.",
    responses={
        401: {
            "description": "Неверные учётные данные",
            "content": {
                "application/json": {
                    "example": {"detail": "Invalid credentials"}
                }
            }
        }
    }
)
def login(form_data: schemas.UserLogin, db: Session = Depends(get_db)):
    user = crud.authenticate_user(db, form_data.login, form_data.password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    access_token = create_access_token({"sub": user.login})
    refresh_token = create_refresh_token({"sub": user.login})
    crud.save_refresh_token(db, user.login, refresh_token)
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post(
    "/logout",
    summary="Выход из системы",
    description="Инвалидирует refresh-токен текущего пользователя. Требует access-токен.",
    responses={
        200: {
            "description": "Успешный выход",
            "content": {
                "application/json": {
                    "example": {"message": "Logged out successfully"}
                }
            }
        },
        401: {"description": "Неавторизован (токен отсутствует или недействителен)"}
    }
)
def logout(
    current_user: Student = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    crud.clear_refresh_token(db, current_user.login)
    return {"message": "Logged out successfully"}

@router.post(
    "/refresh",
    response_model=schemas.TokenResponse,
    summary="Обновление access-токена",
    description="Принимает refresh-токен и возвращает новый access-токен (и тот же refresh).",
    responses={
        401: {
            "description": "Недействительный refresh-токен",
            "content": {
                "application/json": {
                    "example": {"detail": "Invalid refresh token"}
                }
            }
        }
    }
)
def refresh(refresh_req: schemas.RefreshRequest, db: Session = Depends(get_db)):
    payload = decode_token(refresh_req.refresh_token)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(status_code=401, detail="Invalid refresh token")
    login = payload.get("sub")
    if not login:
        raise HTTPException(status_code=401, detail="Invalid token")
    # Проверяем, что такой refresh_token существует в БД
    user = crud.get_user_by_refresh_token(db, refresh_req.refresh_token)
    if not user:
        raise HTTPException(status_code=401, detail="Refresh token not found")
    # Создаём новый access_token
    access_token = create_access_token({"sub": login})
    return {
        "access_token": access_token,
        "refresh_token": refresh_req.refresh_token,  # можно и новый выдать
        "token_type": "bearer"
    }

@router.post(
    "/google/native",
    response_model=schemas.TokenResponse,
    summary="Вход через Google (мобильное приложение)",
    description="Принимает id_token от Google, проверяет его и возвращает access/refresh токены.",
    responses={
        401: {"description": "Недействительный токен Google"},
        400: {"description": "Ошибка при создании пользователя"},
    }
)
def google_native_login(
    google_data: schemas.GoogleNativeLogin,
    db: Session = Depends(get_db)
):
    # 1. Проверяем id_token
    try:
        info = id_token.verify_oauth2_token(
            google_data.id_token,
            requests.Request(),
            os.getenv("GOOGLE_CLIENT_ID")
        )
    except ValueError as e:
        # Недействительный токен
        raise HTTPException(status_code=401, detail=f"Invalid Google token: {str(e)}")

    # 2. Извлекаем данные
    google_id = info.get("sub")
    email = info.get("email")
    name = info.get("name")

    if not google_id:
        raise HTTPException(status_code=400, detail="Google token missing 'sub' claim")

    # 3. Ищем пользователя по google_id
    user = crud.get_user_by_google_id(db, google_id)

    # 4. Если не найден – создаём нового
    if not user:
        google_user_data = {
            "sub": google_id,
            "email": email,
            "name": name
        }
        user = crud.create_user_from_google(db, google_user_data)

    # 5. Генерируем свои токены
    access_token = create_access_token({"sub": user.login})
    refresh_token = create_refresh_token({"sub": user.login})
    crud.save_refresh_token(db, user.login, refresh_token)

    # 6. Возвращаем ответ
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }
