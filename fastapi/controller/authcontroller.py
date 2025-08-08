
from datetime import datetime, timedelta
import socket
from fastapi import HTTPException, Request
from fastapi import Depends, HTTPException, status
from db.models import (user, role, system_log, user_session)
from core.security import create_access_token, create_refresh_token, get_password_hash, verify_password, SECRET_KEY, ALGORITHM
from sqlalchemy.orm import Session
from db.session import get_db
from helper.hepler import log_action
from schemas.user import LoginRequest
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
                                                                                                                                                                                          
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/login")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("name")
        if username is None:
            raise credentials_exception
        user_obj = db.query(user.User).filter(user.User.userName == username).first()
        if user_obj is None:
            raise credentials_exception
        return user_obj
    except JWTError:
        raise credentials_exception
    
def login_controller(request: LoginRequest, db: Session, request_obj: Request = None):
    users = db.query(user.User).filter(user.User.userName == request.username).first()
    if not users or not verify_password(request.password, users.password):
        log_action(
            db=db,
            user_id=None,
            action = "LOGIN_ATTEMPT",
            log_type = "ERROR",
            message=f"Failed login attempt for username: {request.username} from {request.deviceName or 'unknown device'}",
        )
        raise HTTPException(status_code=401, detail="Invalid username or password")
    log_action(
        db=db,
        user_id=users.id,
        action="LOGIN",
        log_type="INFO",
        message=f"User {request.username} logged in successfully from {request.deviceName or 'unknown device'}",
    )

    access_token = create_access_token({"name": users.userName, "password": users.password, "id": users.id, "user_id": users.userID})
    refresh_token = create_refresh_token({"name": users.userName, "password": users.password, "id": users.id, "user_id": users.userID})

    ip_address = request_obj.client.host if request_obj else None
    session = user_session.UserSession(
        user_id = users.id,
        deviceName = request.deviceName,
        access_token = access_token,
        refresh_token = refresh_token,
        token_expired = datetime.utcnow() + timedelta(hours=2),
        refresh_expired = datetime.utcnow() + timedelta(days=7),
        ip_address = ip_address,
        user_agent = request.userAgent,
    )
    db.add(session)
    db.add(system_log.SystemLog(
        action="LOGIN",
        user_id=users.id,
        message=f"User {users.userName} logged in from {request.deviceName or 'unknown device'}",
        logType="INFO",
        hostName=socket.gethostname()
    ))
    db.commit()
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

    access_token = create_access_token({"name": users.userName, "password": users.password, "id": users.id, "user_id": users.userID})
    refresh_token = create_refresh_token({"name": users.userName, "password": users.password, "id": users.id, "user_id": users.userID})
    log_action(
        db=db,
        user_id=users.id,
        action="REGISTER",
        log_type="INFO",
        message=f"User {users.userName} registered successfully",
    )

    access_token = create_access_token({"sub": users.userName})
    refresh_token = create_refresh_token({"sub": users.userName})

    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

def logout_controller(current_user: user.User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        db.query(user_session.UserSession).filter(user_session.UserSession.user_id == current_user.id).delete()
        db.commit()
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to logout: {str(e)}")

    log_action(
        db=db,
        user_id=current_user.id,
        action="LOGOUT",
        log_type="INFO",
        message=f"User {current_user.userName} logged out successfully",
    )

    return {"message": "Successfully logged out"}

