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

# Dependency to get current user from token
@router.post("/me")
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    users = db.query(user.User).filter(user.User.userName == username).first()
    if users is None:
        raise credentials_exception

    return {
        "id": users.userID,
        "username": users.userName,
        "role": users.role_id if users.role_id else None
    }