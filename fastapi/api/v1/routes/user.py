from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from controller import usercontroller
from db.session import get_db
from db.models import (user)
from schemas.user import UpdateUser, UserCreate
from helper.hepler import ConnectionManager

router = APIRouter()
manager = ConnectionManager()

@router.get("/owners")
def get_owners(db: Session = Depends(get_db), current_user: user.User = Depends(usercontroller.get_current_user)):
    return usercontroller.get_owners_controller(db, current_user)

@router.post("/create-owner")
async def create_owner(user_data: UserCreate, request_obj: Request = None, db: Session = Depends(get_db), current_user: user.User = Depends(usercontroller.get_current_user)):
    owner = usercontroller.create_owner_controller(user_data, db, current_user, request_obj)
    await manager.broadcast({
        "action": "create",
        "data": owner
    })
    return owner

@router.put("/update-owner/{id}")
async def update_owner(id: str, user_data: UpdateUser, request_obj: Request = None, db: Session = Depends(get_db), current_user: user.User = Depends(usercontroller.get_current_user)):
    owner = usercontroller.update_owner_controller(id, user_data, db, current_user, request_obj)
    await manager.broadcast({
        "action": "update",
        "id": id,
        "data": owner
    })
    return owner

@router.delete("/delete-owner/{id}")
async def delete_owner(id: str, request_obj: Request = None, db: Session = Depends(get_db), current_user: user.User = Depends(usercontroller.get_current_user)):
    owner = usercontroller.delete_owner_controller(id, db, current_user, request_obj)
    await manager.broadcast({
        "action": "delete",
        "id": id
    })
    return owner