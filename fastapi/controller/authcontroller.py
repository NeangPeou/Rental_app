
from datetime import datetime, timedelta
from fastapi import HTTPException
from db.models import (user, role, system_log, user_session)
from core.security import create_access_token, create_refresh_token, get_password_hash, verify_password
from sqlalchemy.orm import Session
from schemas.user import LoginRequest

def login_controller(request: LoginRequest, db: Session):
    users = db.query(user.User).filter(user.User.userName == request.username).first()
    if not users or not verify_password(request.password, users.password):
        raise HTTPException(status_code=401, detail="Invalid username or password")

    access_token = create_access_token({"sub": users.userName})
    refresh_token = create_refresh_token({"sub": users.userName})

    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

def register_controller(request: LoginRequest, db: Session):
    existing_user = db.query(user.User).filter(user.User.userName == request.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already exists")

    # Assign default role or create if not exists
    roles = db.query(role.Role).filter(role.Role.role == "Admin").first()
    if not roles:
        roles = role.Role(role="Admin")
        db.add(roles)
        db.commit()
        db.refresh(roles)

    hashed_password = get_password_hash(request.password)
    users = user.User(userName=request.username, password=hashed_password, role_id=roles.id)
    db.add(users)
    db.commit()
    db.refresh(users)

    access_token = create_access_token({"sub": users.userName})
    refresh_token = create_refresh_token({"sub": users.userName})

    session = user_session.UserSession(user_id=users.id, access_token=access_token, refresh_token=refresh_token, token_expired=datetime.utcnow() + timedelta(hours=2))
    db.add(session)
    db.add(system_log.SystemLog(action="Admin Registration", user_id=users.id))
    db.commit()

    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}