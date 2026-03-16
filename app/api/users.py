from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.orm import Session
from .. import crud, schemas
from ..database import SessionLocal
from ..core.deps import get_current_user
from ..models import Student
from ..core.security import create_access_token, create_refresh_token

router = APIRouter(prefix="/api/v1/user", tags=["users"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Удаление своего профиля – требуется авторизация
@router.delete(
    "/me",
    summary="Удаление профиля",
    description="Полностью удаляет текущего пользователя. Требует авторизации.",
    responses={
        200: {
            "description": "Успешно удалено",
            "content": {
                "application/json": {
                    "example": {"message": "User deleted successfully"}
                }
            }
        },
        401: {"description": "Неавторизован"}
    }
)
def delete_my_account(
    current_user: Student = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    crud.delete_user(db, current_user.login)
    return {"message": "User deleted successfully"}

# ... другие эндпоинты

@router.get(
    "/me",
    response_model=schemas.PublicUser,
    summary="Получить профиль текущего пользователя",
    description="Возвращает информацию о пользователе на основе access-токена",
    openapi_extra={
        "parameters": [
            {
                "name": "Authorization",
                "in": "header",
                "required": True,
                "schema": {"type": "string"},
                "description": "Bearer-acssess-токеn",
                "example": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
            }
        ]
    },
    responses={
        200: {
            "description": "Успешный ответ",
            "content": {
                "application/json": {
                    "example": {
                        "login": "ivanov",
                        "user_name": "Иван Иванов"
                    }
                }
            }
        },
        401: {"description": "Неавторизован (токен отсутствует или недействителен)"}
    }
)
def read_current_user(current_user: Student = Depends(get_current_user)):
    return current_user


# new router for update
update_router = APIRouter(prefix="/update")

@update_router.patch(
    "/username",
    response_model=schemas.UsernameUpdateResponse,
    summary="Смена имени пользователя",
    description="Обновляет отображаемое имя (username) текущего пользователя.",
    responses={
        200: {
            "description": "Имя успешно обновлено",
            "content": {
                "application/json": {
                    "example": {
                        "user_name": "Новое имя"
                    }
                }
            }
        },
        401: {"description": "Неавторизован"},
        404: {"description": "Пользователь не найден"}
    }
)
def update_username(
    request: schemas.UpdateUsernameRequest,
    current_user: Student = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    updated_user = crud.update_username(db, current_user.login, request.new_username)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"user_name": updated_user.user_name}

@update_router.patch(
    "/login",
    response_model=schemas.LoginUpdateResponse,
    summary="Смена логина",
    description=(
        "Изменяет логин пользователя. "
        "После смены логина все старые токены становятся недействительными, "
        "в ответе выдаются новые access и refresh токены, а также обновлённый логин."
    ),
    responses={
        200: {
            "description": "Логин успешно изменён, новые токены выданы",
            "content": {
                "application/json": {
                    "example": {
                        "access_token": "eyJhbGciOiJIUzI1NiIs...",
                        "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
                        "token_type": "bearer",
                        "login": "new_ivanov"
                    }
                }
            }
        },
        400: {"description": "Логин уже занят"},
        401: {"description": "Неавторизован"},
        404: {"description": "Пользователь не найден"}
    }
)
def update_login(
    request: schemas.UpdateLoginRequest,
    current_user: Student = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        updated_user = crud.update_login(db, current_user.login, request.new_login)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    access_token = create_access_token({"sub": updated_user.login})
    refresh_token = create_refresh_token({"sub": updated_user.login})
    crud.save_refresh_token(db, updated_user.login, refresh_token)
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "login": updated_user.login
    }

@update_router.patch(
    "/password",
    status_code=200,
    summary="Смена пароля",
    description="Обновляет пароль текущего пользователя. Возвращает только статус 200 при успехе.",
    responses={
        200: {"description": "Пароль успешно обновлён"},
        401: {"description": "Неавторизован"},
        404: {"description": "Данные пользователя не найдены"}
    }
)
def update_password(
    request: schemas.UpdatePasswordRequest,
    current_user: Student = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    success = crud.update_password(db, current_user.login, request.new_password)
    if not success:
        raise HTTPException(status_code=404, detail="User data not found")
    return Response(status_code=200, content=None)

# Подключаем подроутер к основному роутеру
router.include_router(update_router)
