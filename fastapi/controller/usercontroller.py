
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from db.models import (user, role, system_log)
from core.security import get_password_hash, SECRET_KEY, ALGORITHM
from helper.hepler import log_action
from schemas.user import UpdateUser, UserCreate
from db.session import get_db
from jose import JWTError, jwt
from sqlalchemy import desc

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/login")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM], options={"verify_exp": False})
        username: str = payload.get("name")
        if username is None:
            raise credentials_exception
        user_obj = db.query(user.User).filter(user.User.userName == username).first()
        if user_obj is None:
            raise credentials_exception
        return user_obj
    except JWTError as e:
        raise credentials_exception

def generate_user_id(db: Session):
    latest_user = db.query(user.User).filter(user.User.userID.like("sw_rental_%")).order_by(user.User.userID.desc()).first()
    if not latest_user:
        return "sw_rental_001" 
    latest_id = latest_user.userID
    number = int(latest_id.replace("sw_rental_", ""))
    new_number = number + 1
    return f"sw_rental_{new_number:03d}"


def get_owners_controller(db: Session, current_user: user.User = Depends(get_current_user)):
    try:
        admin_role = db.query(role.Role).filter(role.Role.role == "Admin").first()
        if not admin_role or current_user.role_id != admin_role.id:
            raise HTTPException(status_code=403, detail="Only admins can access owner list")

        owner_role = db.query(role.Role).filter(role.Role.role == "Owner").first()
        if not owner_role:
            raise HTTPException(status_code=404, detail="Owner role not found")

        owners = db.query(user.User).filter(user.User.role_id == owner_role.id).order_by(desc(user.User.id)).all()
        return owners
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch owners: {str(e)}")

def create_owner_controller(
    user_data: UserCreate, 
    db: Session, 
    current_user: user.User = Depends(get_current_user),
    request_obj: Request = None
):
    try:
        admin_role = db.query(role.Role).filter(role.Role.role == "Admin").first()
        if not admin_role or current_user.role_id != admin_role.id:
            raise HTTPException(status_code=403, detail="Only admins can create owners")

        existing_user = db.query(user.User).filter(user.User.userName == user_data.username).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="Username already exists")

        owner_role = db.query(role.Role).filter(role.Role.role == "Owner").first()
        if not owner_role:
            owner_role = role.Role(role="Owner", description="Property owner role")
            db.add(owner_role)
            db.commit()
            db.refresh(owner_role)

        hashed_password = get_password_hash(user_data.password)
        user_id = generate_user_id(db)
        users = user.User(
            userID=user_id,
            userName=user_data.username,
            password=hashed_password,
            role_id=owner_role.id,
            phoneNumber=user_data.phoneNumber,
            passport=user_data.passport,
            idCard=user_data.idCard,
            address=user_data.address
        )
        db.add(users)
        db.commit()
        db.refresh(users)

        ip_address = request_obj.client.host if request_obj else 'unknown'
        host_name = user_data.deviceName if hasattr(user_data, 'deviceName') else ip_address or 'unknown'
        log_action(
            db=db,
            user_id=users.id,
            action="CREATE_OWNER",
            log_type="INFO",
            message=f"Owner {users.userName} created by admin {current_user.userName}",
            host_name=host_name
        )

        return {"message": f"Owner {users.userName} created successfully", "user_id": users.userID}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to create owner: {str(e)}")
    
def update_owner_controller(
    user_id: str,
    user_data: UpdateUser,
    db: Session,
    current_user: user.User = Depends(get_current_user),
    request_obj: Request = None
):
    try:
        admin_role = db.query(role.Role).filter(role.Role.role == "Admin").first()
        if not admin_role or current_user.role_id != admin_role.id:
            raise HTTPException(status_code=403, detail="Only admins can update owners")

        owner = db.query(user.User).filter(user.User.userID == user_id).first()
        if not owner:
            raise HTTPException(status_code=404, detail="Owner not found")

        owner_role = db.query(role.Role).filter(role.Role.role == "Owner").first()
        if not owner_role or owner.role_id != owner_role.id:
            raise HTTPException(status_code=400, detail="User is not an owner")

        if user_data.username and user_data.username != owner.userName:
            existing_user = db.query(user.User).filter(user.User.userName == user_data.username).first()
            if existing_user:
                raise HTTPException(status_code=400, detail="Username already exists")

        if user_data.username is not None:
            owner.userName = user_data.username
        if user_data.password is not None:
            owner.password = get_password_hash(user_data.password)
        if user_data.phoneNumber is not None:
            owner.phoneNumber = user_data.phoneNumber or None
        if user_data.passport is not None:
            owner.passport = user_data.passport or None
        if user_data.idCard is not None:
            owner.idCard = user_data.idCard or None
        if user_data.address is not None:
            owner.address = user_data.address or None

        db.commit()
        db.refresh(owner)

        ip_address = request_obj.client.host if request_obj else 'unknown'
        host_name = user_data.deviceName if hasattr(user_data, 'deviceName') else ip_address or 'unknown'
        log_action(
            db=db,
            user_id=owner.id,
            action="UPDATE_OWNER",
            log_type="INFO",
            message=f"Owner {owner.userName} updated by admin {current_user.userName}",
            host_name=host_name
        )

        return {"message": f"Owner {owner.userName} updated successfully", "user_id": owner.userID}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to update owner: {str(e)}")
    
def delete_owner_controller(
    user_id: str,
    db: Session,
    current_user: user.User = Depends(get_current_user),
    request_obj: Request = None
):
    try:
        admin_role = db.query(role.Role).filter(role.Role.role == "Admin").first()
        if not admin_role or current_user.role_id != admin_role.id:
            raise HTTPException(status_code=403, detail="Only admins can delete owners")

        owner = db.query(user.User).filter(user.User.userID == user_id).first()
        if not owner:
            raise HTTPException(status_code=404, detail="Owner not found")

        owner_role = db.query(role.Role).filter(role.Role.role == "Owner").first()
        if not owner_role or owner.role_id != owner_role.id:
            raise HTTPException(status_code=400, detail="User is not an owner")
        # Delete associated system logs
        db.query(system_log.SystemLog).filter(system_log.SystemLog.user_id == owner.id).delete()

        db.delete(owner)
        db.commit()

        ip_address = request_obj.client.host if request_obj else 'unknown'
        log_action(
            db=db,
            user_id=current_user.id,
            action="DELETE_OWNER",
            log_type="INFO",
            message=f"Owner {owner.userName} and associated logs deleted by {current_user.userName}",
            host_name=ip_address
        )

        return {"message": f"Owner {owner.userName} and associated logs deleted successfully", "user_id": owner.userID}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to delete owner and logs: {str(e)}")
