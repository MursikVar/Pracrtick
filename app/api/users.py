from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import crud, schemas
from ..database import SessionLocal
from ..core.deps import get_current_user
from ..models import Student

router = APIRouter(prefix="/api/v1/user", tags=["users"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Публичный профиль – доступен всем
#@router.get("/{login}", response_model=schemas.PublicUser)
#def read_user(request: Request, login: str, db: Session = Depends(get_db)):
#    print(f"[HTTP] Request to {request.url.path}")
#    db_user = crud.get_user_by_login(db, login)
#    if db_user is None:
#        raise HTTPException(status_code=404, detail="User not found")
#    return db_user

# Обновление своего профиля – требуется авторизация
@router.patch(
    "/me",
    response_model=schemas.PublicUser,
    summary="Обновление профиля",
    description="Обновляет имя пользователя (или другие поля). Требует авторизации.",
    responses={
        200: {
            "description": "Успешно обновлено",
            "content": {
                "application/json": {
                    "example": {
                        "login": "ivanov",
                        "user_name": "Новое имя"
                    }
                }
            }
        },
        401: {"description": "Неавторизован"}
    }
)
def update_my_profile(
    user_update: schemas.UserUpdate,
    current_user: Student = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Разрешаем обновлять только собственные данные
    updated_user = crud.update_user(db, current_user.login, user_update)
    return updated_user

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
