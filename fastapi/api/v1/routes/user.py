from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from controller import usercontroller
from db.session import get_db
from db.models import (user)
from schemas.user import UserCreate

router = APIRouter()

@router.post("/create-owner")
def create_owner(
    user_data: UserCreate, 
    request_obj: Request = None,
    db: Session = Depends(get_db), 
    current_user: user.User = Depends(usercontroller.get_current_user)
):
    return usercontroller.create_owner_controller(user_data, db, current_user, request_obj)