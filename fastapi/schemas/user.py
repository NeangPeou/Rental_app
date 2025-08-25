from typing import Optional
from pydantic import BaseModel, Field

class RegisterUser(BaseModel):
    username: str
    password: str
    phoneNumber: Optional[str] = None
    deviceName: Optional[str] = None
    passport: Optional[str] = None
    idCard: Optional[str] = None 
    address: Optional[str] = None

class LoginRequest(BaseModel):
    username: str
    password: str
    deviceName: Optional[str] = Field(default=None, alias="device_name")
    userAgent: Optional[str] = Field(default=None, alias="user_agent")

    class Config:
        populate_by_name = True

class UserCreate(BaseModel):
    username: str
    password: str
    phoneNumber: Optional[str] = None
    passport: Optional[str] = None
    idCard: Optional[str] = None
    address: Optional[str] = None
    deviceName: Optional[str] = None
    gender: Optional[str] = Field(
        default='Unknown',
        description="Valid values: Male, Female, Other,"
    )

class UserResponse(BaseModel):
    id: int
    userID: Optional[str] = None
    userName: str
    phoneNumber: Optional[str] = None
    passport: Optional[str] = None
    idCard: Optional[str] = None
    address: Optional[str] = None

    gender: Optional[str] = Field(
        default='Unknown',
        description="Valid values: Male, Female"
    )

    accessToken: Optional[str] = None
    refreshToken: Optional[str] = None

    model_config = {
        "from_attributes": True
    }

class TokenResponse(BaseModel):
    accessToken: str
    refreshToken: str
    tokenType: str = "bearer"
    user: UserResponse

class UpdateUser(BaseModel):
    username: Optional[str] = None
    password: Optional[str] = None
    phoneNumber: Optional[str] = None
    passport: Optional[str] = None
    idCard: Optional[str] = None
    address: Optional[str] = None
    deviceName: Optional[str] = None

    gender: Optional[str] = Field(
        default=None,
        description="Valid values: Male, Female"
    )