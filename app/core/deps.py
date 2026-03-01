from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from jose import JWTError
from ..database import SessionLocal
from ..core.security import decode_token
from .. import crud
import traceback

security = HTTPBearer()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    token = credentials.credentials
    payload = decode_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Invalid token")
    login = payload.get("sub")
    if not login:
        raise HTTPException(status_code=401, detail="Invalid token")
    user = crud.get_user_by_login(db, login)
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    return user
