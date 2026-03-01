from pydantic import BaseModel, Field
from typing import Optional

# 1. Регистрация
class UserRegister(BaseModel):
    login: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=6)
    user_name: Optional[str] = None

# 2. Вход
class UserLogin(BaseModel):
    login: str
    password: str

# 3. Ответ с токенами
class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

# 4. Запрос на обновление токена
class RefreshRequest(BaseModel):
    refresh_token: str

# 5. Публичный профиль (без пароля и токенов)
class PublicUser(BaseModel):
    login: str
    user_name: Optional[str] = None

    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "login": "ivanov",
                "user_name": "Иван Иванов"
            }
        }
# 6.
class UserUpdate(BaseModel):
    user_name: Optional[str] = None
    # другие изменяемые поля (но не пароль и токены)
