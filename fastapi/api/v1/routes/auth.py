import bcrypt
from fastapi import APIRouter, Depends, HTTPException, Request, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer
from controller import authcontroller
from db.session import get_db
from db.models import (user)
from core.security import ALGORITHM, SECRET_KEY, verify_password
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

@router.post("/tokensValid")
def token_is_valid(request: Request, db: Session = Depends(get_db)):
    auth_header = request.headers.get("authorization")
    if not auth_header:
        raise HTTPException(status_code=403, detail="Authorization header missing")

    if not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=403, detail="Invalid auth scheme")

    token = auth_header.split(" ")[1]

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    
        username_from_token = payload.get("name")
        password_from_token = payload.get("password") 
        
        if not username_from_token or not password_from_token:
            raise HTTPException(status_code=400, detail="Token missing username or password")

        userData = db.query(user.User).filter(user.User.userName == username_from_token).first()

        if not userData:
            raise HTTPException(status_code=404, detail="User not found")

        # Check password (hashed) against the password in token (usually NOT safe to store raw password in token)
        if password_from_token != userData.password:
            raise HTTPException(status_code=401, detail="Invalid credentials")

        return {
            "valid": True,
            "user_id": userData.userID,
            "username": userData.userName,
            "phone": userData.phoneNumber
        }
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

# Dependency to get current user from token
# @router.post("/me")
# def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
#     credentials_exception = HTTPException(
#         status_code=status.HTTP_401_UNAUTHORIZED,
#         detail="Could not validate credentials",
#     )
#     try:
#         payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
#         username: str = payload.get("sub")
#         if username is None:
#             raise credentials_exception
#     except JWTError:
#         raise credentials_exception

#     users = db.query(user.User).filter(user.User.userName == username).first()
#     if users is None:
#         raise credentials_exception

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