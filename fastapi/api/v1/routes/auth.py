from fastapi import APIRouter, Depends, HTTPException, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from controller import authcontroller
from db.session import get_db
from db.models import (user)
from core.security import ALGORITHM, SECRET_KEY
from schemas.user import LoginRequest, RegisterUser, TokenResponse

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

@router.post("/logout")
def logout(current_user: user.User = Depends(authcontroller.get_current_user), db: Session = Depends(get_db)):
    return authcontroller.logout_controller(current_user, db)

@router.get("/me")
def get_current_user(current_user: user.User = Depends(authcontroller.get_current_user)):
    return {
        "id": current_user.userID,
        "username": current_user.userName,
        "role": current_user.role_id if current_user.role_id else None
    }