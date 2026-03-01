from sqlalchemy.orm import Session
from . import models, schemas
from .core.security import get_password_hash, verify_password
from sqlalchemy import text
import traceback

def get_user_by_login(db: Session, login: str):
    return db.query(models.Student).filter(models.Student.login == login).first()

def create_user(db: Session, user_data: schemas.UserRegister):
    # hashed = get_password_hash(user_data.password)
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
    if not data or data.password != password:  # прямое сравнение (небезопасно!)
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

def update_user(db: Session, login: str, user_update: schemas.UserUpdate):
    db_student = db.query(models.Student).filter(models.Student.login == login).first()
    if db_student and user_update.user_name is not None:
        db_student.user_name = user_update.user_name
    db.commit()
    db.refresh(db_student)
    return db_student

def delete_user(db: Session, login: str):
    db_data = db.query(models.Data).filter(models.Data.login == login).first()
    if db_data:
        db.delete(db_data)
    db_student = db.query(models.Student).filter(models.Student.login == login).first()
    if db_student:
        db.delete(db_student)
    db.commit()
    return True



