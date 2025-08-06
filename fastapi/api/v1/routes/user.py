from datetime import datetime, timedelta
from fastapi import APIRouter, Body, Depends, HTTPException
from sqlalchemy.orm import Session
from core.security import create_access_token, create_refresh_token, decode_token, verify_password
from db.models.role import Role
from db.models.system_log import SystemLog
from db.models.user_session import UserSession
from db.session import get_db
from db.models.user import User
from schemas.user import LoginRequest, RegisterUser, TokenResponse
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from core.security import create_access_token, create_refresh_token, get_password_hash
from db.session import get_db
from db.models import User, Role, UserSession, SystemLog

router = APIRouter()

@router.post("/register", response_model=TokenResponse)
def register_admin(data: RegisterUser, db: Session = Depends(get_db)):
    # 1. Check or create admin role
    role = db.query(Role).filter(Role.name == "Admin").first()
    if not role:
        role = Role(name="Admin")
        db.add(role)
        db.commit()
        db.refresh(role)

    # 2. Check if username exists
    if db.query(User).filter(User.username == data.username).first():
        raise HTTPException(status_code=400, detail="Username already exists")

    # 3. Hash password
    hashed_password = get_password_hash(data.password)

    # 4. Create user
    user = User(
        username=data.username,
        password=hashed_password,
        role_id=role.id,
        is_active=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # 5. Create access and refresh tokens (expires_delta optional)
    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=timedelta(minutes=30)
    )
    refresh_token = create_refresh_token(
        data={"sub": user.username},
        expires_delta=timedelta(days=7)
    )

    # 6. Optionally save refresh token in UserSession table for blacklisting or tracking
    session = UserSession(
        user_id=user.id,
        token=refresh_token,
        expired_at=datetime.utcnow() + timedelta(days=7),
    )
    db.add(session)

    # 7. Log registration event
    log = SystemLog(
        action="Admin Registration",
        user_id=user.id,
        created_at=datetime.utcnow()
    )
    db.add(log)

    db.commit()

    # 8. Return tokens
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/refresh", response_model=TokenResponse)
def refresh_token(refresh_token: str = Body(...), db: Session = Depends(get_db)):
    payload = decode_token(refresh_token)
    if not payload or "sub" not in payload:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    username = payload["sub"]
    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")

    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=timedelta(minutes=30)
    )
    new_refresh_token = create_refresh_token(
        data={"sub": user.username},
        expires_delta=timedelta(days=7)
    )

    return {
        "access_token": access_token,
        "refresh_token": new_refresh_token
    }

@router.post("/login", response_model=TokenResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == request.username).first()
    if not user or not verify_password(request.password, user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Inactive user")

    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=timedelta(minutes=30)
    )
    refresh_token = create_refresh_token(
        data={"sub": user.username},
        expires_delta=timedelta(days=7)
    )

    return {
        "access_token": access_token,
        "refresh_token": refresh_token
    }
