from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import User, Role, UserSession, SystemLog
from ..schemas import RegisterAdmin, RegisterRental, LoginAdmin, LoginRental
from passlib.hash import bcrypt
import uuid
from datetime import datetime, timedelta

router = APIRouter()

# 🔹 Admin Register
@router.post("/admin/register")
def register_admin(data: RegisterAdmin, db: Session = Depends(get_db)):
    # Check for existing Admin role
    role = db.query(Role).filter(Role.name == "Admin").first()
    if not role:
        role = Role(name="Admin")
        db.add(role)
        db.commit()
        db.refresh(role)

    # Check if username exists
    if db.query(User).filter(User.username == data.username).first():
        raise HTTPException(status_code=400, detail="Username already exists")

    # Create new user
    user = User(
        username=data.username,
        password=bcrypt.hash(data.password),
        role_id=role.id
    )
    db.add(user)
    db.commit()
    db.refresh(user)  # Now user.id is available

    # Generate session token
    token = str(uuid.uuid4())
    session = UserSession(user_id=user.id, token=token, expired_at=datetime.utcnow() + timedelta(hours=2))
    db.add(session)
    db.add(SystemLog(action="Admin Registration", user_id=user.id))
    db.commit()

    return {
        "message": "Admin registered successfully",
        "token": token
    }

# 🔹 Admin Login
@router.post("/admin/login")
def admin_login(data: LoginAdmin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == data.username).first()
    if not user or not bcrypt.verify(data.password, user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if user.role.name != "Admin":
        raise HTTPException(status_code=403, detail="Not an Admin")

    token = str(uuid.uuid4())
    session = UserSession(user_id=user.id, token=token, expired_at=datetime.utcnow() + timedelta(hours=2))
    db.add(session)
    db.add(SystemLog(action="Admin Login", user_id=user.id))
    db.commit()
    return {"message": "Admin login successful", "token": token}

# 🔹 Rental Register
@router.post("/rental/register")
def register_rental(data: RegisterRental, db: Session = Depends(get_db)):
    role = db.query(Role).filter(Role.name == "Rental").first()
    if not role:
        role = Role(name="Rental")
        db.add(role)
        db.commit()
        db.refresh(role)

    if db.query(User).filter(User.username == data.username).first():
        raise HTTPException(status_code=400, detail="Username already exists")

    user = User(username=data.username, password=bcrypt.hash(data.password), code=data.code, role_id=role.id)
    db.add(user)
    db.commit()
    return {"message": "Rental user registered successfully"}

# 🔹 Rental Login
@router.post("/rental/login")
def rental_login(data: LoginRental, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == data.username, User.code == data.code).first()
    if not user or not bcrypt.verify(data.password, user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    if user.role.name != "Rental":
        raise HTTPException(status_code=403, detail="Not a Rental user")

    token = str(uuid.uuid4())
    session = UserSession(user_id=user.id, token=token, expired_at=datetime.utcnow() + timedelta(hours=2))
    db.add(session)
    db.add(SystemLog(action="Rental Login", user_id=user.id))
    db.commit()
    return {"message": "Rental login successful", "token": token}
