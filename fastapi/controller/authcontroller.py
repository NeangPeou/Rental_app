
from datetime import datetime, timedelta
from fastapi import HTTPException, Request
from fastapi import HTTPException
from db.models import (user, role, system_log, user_session)
from core.security import create_access_token, create_refresh_token, get_password_hash, verify_password, SECRET_KEY, ALGORITHM
from sqlalchemy.orm import Session
from controller.usercontroller import generate_user_id
from helper.hepler import log_action
from schemas.user import LoginRequest, RegisterUser
from jose import jwt
    
def login_controller(request: LoginRequest, db: Session, request_obj: Request = None):
    users = db.query(user.User).filter(user.User.userName == request.username).first()
    if not users or not verify_password(request.password, users.password):
        log_action(
            db=db,
            user_id=None,
            action = "LOGIN_ATTEMPT",
            log_type = "ERROR",
            message=f"Failed login attempt for username: {request.username} from {request.deviceName or 'unknown device'}",
            host_name=request.deviceName or 'unknown'
        )
        raise HTTPException(status_code=401, detail="Invalid username or password")

    access_token = create_access_token({"name": users.userName, "password": users.password, "id": users.id})
    refresh_token = create_refresh_token({"name": users.userName, "password": users.password, "id": users.id})

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
        hostName=request.deviceName or 'unknown'
    ))
    db.commit()
    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

def register_controller(user_data: RegisterUser, db: Session, request_obj: Request = None):
    existing_user = db.query(user.User).filter(user.User.userName == user_data.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already exists")

    # Assign default role or create if not exists
    roles = db.query(role.Role).filter(role.Role.role == "Admin").first()
    if not roles:
        roles = role.Role(role="Admin")
        db.add(roles)
        db.commit()
        db.refresh(roles)

    hashed_password = get_password_hash(user_data.password)
    # user_id = generate_user_id(db)
    users = user.User(
        userName=user_data.username,
        password=hashed_password,
        role_id=roles.id,
        phoneNumber=user_data.phoneNumber,
        passport=user_data.passport,
        idCard=user_data.idCard,
        address=user_data.address
    )
    db.add(users)
    db.commit()
    db.refresh(users)

    # Extract hostName from request_obj or use a fallback
    ip_address = request_obj.client.host if request_obj else 'unknown'
    host_name = user_data.deviceName if hasattr(user_data, 'deviceName') else ip_address or 'unknown'

    log_action(
        db=db,
        user_id=users.id,
        action="REGISTER",
        log_type="INFO",
        message=f"User {users.userName} registered successfully",
        host_name=host_name
    )

    access_token = create_access_token({"name": users.userName, "id": users.id})
    refresh_token = create_refresh_token({"name": users.userName, "id": users.id})

    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

def logout_controller(request: Request, db: Session):
    try:
        token = request.headers.get("Authorization", "").replace("Bearer ", "")
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM], options={"verify_exp": False})
        user_obj = db.query(user.User).filter_by(userName=payload.get("name")).first()

        if not user_obj:
            return {"message": "Successfully logged out"}  # no user found

        session_data = db.query(user_session.UserSession).filter_by(access_token=token).first()
        if not session_data:
            return {"message": "Successfully logged out"}  # no session found
        host_name = session_data.deviceName or request.client.host or "unknown"

        db.query(user_session.UserSession).filter_by(access_token=token).delete()
        log_action(
            db=db,
            user_id=user_obj.id,
            action="LOGOUT",
            log_type="INFO",
            message=f"User {user_obj.userName} logged out successfully from {host_name}",
            host_name=host_name
        )

        db.commit()
        return {"message": "Successfully logged out"}

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to logout: {str(e)}")

