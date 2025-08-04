from pydantic import BaseModel

class RegisterAdmin(BaseModel):
    username: str
    password: str

class RegisterRental(BaseModel):
    code: str
    username: str
    password: str

class LoginAdmin(BaseModel):
    username: str
    password: str

class LoginRental(BaseModel):
    code: str
    username: str
    password: str
