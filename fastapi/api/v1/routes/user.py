from typing import List
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from controller import usercontroller
from db.session import get_db
from db.models import (user)
from schemas.user import UpdateUser, UserCreate, UserResponse

router = APIRouter()

@router.get("/owners")
def get_owners(
    db: Session = Depends(get_db),
    current_user: user.User = Depends(usercontroller.get_current_user)
):
    return usercontroller.get_owners_controller(db, current_user)

@router.post("/create-owner")
def create_owner(
    user_data: UserCreate, 
    request_obj: Request = None,
    db: Session = Depends(get_db), 
    current_user: user.User = Depends(usercontroller.get_current_user)
):
    return usercontroller.create_owner_controller(user_data, db, current_user, request_obj)

@router.put("/update-owner/{id}")
def update_owner(
    id: str,
    user_data: UpdateUser,
    request_obj: Request = None,
    db: Session = Depends(get_db),
    current_user: user.User = Depends(usercontroller.get_current_user)
):
    return usercontroller.update_owner_controller(id, user_data, db, current_user, request_obj)

@router.delete("/delete-owner/{id}")
def delete_owner(
    id: str,
    request_obj: Request = None,
    db: Session = Depends(get_db),
    current_user: user.User = Depends(usercontroller.get_current_user)
):
    return usercontroller.delete_owner_controller(id, db, current_user, request_obj)