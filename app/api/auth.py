from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import schemas, crud
from ..database import SessionLocal
from ..core.security import create_access_token, create_refresh_token, decode_token
from datetime import timedelta
from ..core.deps import get_db, security, get_current_user
from ..models import Student

router = APIRouter(prefix="/api/v1/auth", tags=["authentication"])

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
