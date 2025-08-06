from fastapi import APIRouter, Depends

router = APIRouter()

# @router.get("/me", response_model=TokenResponse)
# def get_current_user(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
#     role = db.query(Role).filter(Role.id == current_user.role_id).first()
#     return {
#         "id": current_user.id,
#         "UserID": current_user.UserID,
#         "UserName": current_user.UserName,
#         "email": current_user.email,
#         "PhoneNumber": current_user.PhoneNumber,
#         "role_id": current_user.role_id,
#         "role": {
#             "id": role.id, 
#             "role": role.role, 
#             "description": role.description
#         } if role else None
#     }
