from sqlalchemy.orm import Session
from . import models, schemas
from .core.security import get_password_hash, verify_password
from sqlalchemy import text
import traceback

def get_user_by_login(db: Session, login: str):
    return db.query(models.Student).filter(models.Student.login == login).first()

def create_user(db: Session, user_data: schemas.UserRegister):
    db_student = models.Student(
        login=user_data.login,
        user_name=user_data.user_name or user_data.login
    )
    db.add(db_student)
    db.flush()
    db_data = models.Data(
        login=user_data.login,
        password=user_data.password
    )
    db.add(db_data)
    db.commit()
    db.refresh(db_student)
    return db_student

def authenticate_user(db: Session, login: str, password: str):
    user = get_user_by_login(db, login)
    if not user:
        return None
    data = db.query(models.Data).filter(models.Data.login == login).first()
    if not data or data.password != password:
        return None
    return user

def save_refresh_token(db: Session, login: str, refresh_token: str):
    data = db.query(models.Data).filter(models.Data.login == login).first()
    if data:
        data.refresh_token = refresh_token
        db.commit()

def get_user_by_refresh_token(db: Session, refresh_token: str):
    data = db.query(models.Data).filter(models.Data.refresh_token == refresh_token).first()
    if data:
        return get_user_by_login(db, data.login)
    return None

def clear_refresh_token(db: Session, login: str):
    data = db.query(models.Data).filter(models.Data.login == login).first()
    if data:
        data.refresh_token = None
        db.commit()

def update_username(db: Session, login: str, new_username: str):
    student = db.query(models.Student).filter(models.Student.login == login).first()
    if not student:
        return None
    student.user_name = new_username
    db.commit()
    db.refresh(student)
    return student

def update_login(db: Session, current_login: str, new_login: str):
    if db.query(models.Student).filter(models.Student.login == new_login).first():
        raise ValueError("Login already exists")
    
    student = db.query(models.Student).filter(models.Student.login == current_login).first()
    if not student:
        return None
    
    student.login = new_login
    db.commit()
    db.refresh(student)
    return student

def update_password(db: Session, login: str, new_password: str):
    data = db.query(models.Data).filter(models.Data.login == login).first()
    if not data:
        return None
    data.password = new_password
    db.commit()
    return True


def delete_user(db: Session, login: str):
    db_data = db.query(models.Data).filter(models.Data.login == login).first()
    if db_data:
        db.delete(db_data)
    db_student = db.query(models.Student).filter(models.Student.login == login).first()
    if db_student:
        db.delete(db_student)
    db.commit()
    return True

def get_user_by_google_id(db: Session, google_id: str):
    """Возвращает пользователя (Student) по google_id из таблицы Data."""
    data = db.query(models.Data).filter(models.Data.google_id == google_id).first()
    if data:
        return db.query(models.Student).filter(models.Student.login == data.login).first()
    return None

def create_user_from_google(db: Session, google_data: dict) -> models.Student:
    """
    google_data должен содержать ключи:
    - sub (обязательный)
    - email (опционально)
    - name (опционально)
    """
    # Генерируем логин. Если есть email, используем его часть до @, иначе берём префикс от sub.
    if google_data.get("email"):
        login = google_data["email"].split("@")[0]
    else:
        login = f"google_{google_data['sub'][:8]}"

    # Убедимся, что логин уникален (если занят, добавим суффикс)
    base_login = login
    counter = 1
    while db.query(models.Student).filter(models.Student.login == login).first():
        login = f"{base_login}{counter}"
        counter += 1

    # Создаём запись в student
    student = models.Student(
        login=login,
        user_name=google_data.get("name", "")
    )
    db.add(student)
    db.flush()  # получаем login (он же primary key)

    # Создаём запись в data
    data = models.Data(
        login=login,
        google_id=google_data["sub"],
        # другие поля оставляем пустыми (пароль не нужен)
    )
    db.add(data)
    db.commit()
    db.refresh(student)
    return student

