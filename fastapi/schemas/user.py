from pydantic import BaseModel, Field

class RegisterUser(BaseModel):
    username: str
    password: str
    deviceName: str | None = None

class LoginRequest(BaseModel):
    username: str
    password: str
    deviceName: str | None = Field(default=None, alias="device_name")
    userAgent: str | None = Field(default=None, alias="user_agent")

    class Config:
        populate_by_name = True

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
