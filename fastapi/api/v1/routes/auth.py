from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer
from controller import authcontroller
from core.security import (
    decode_token,
)
from db.session import get_db
from db.models.user import User
from schemas.user import RegisterUser, LoginRequest, TokenResponse

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/login")

@router.post("/register", response_model=TokenResponse)
def register(user_data: RegisterUser, db: Session = Depends(get_db)):
    user = authcontroller.register_controller(user_data, db)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/login", response_model=TokenResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    user = authcontroller.login_controller(request, db)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# Dependency to get current user from token
@router.get("/profile")
def profile(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_token(token)
    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid authentication credentials")
    username = payload["sub"]
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"username": user.username, "role": user.role.name if user.role else None}
