from pydantic import BaseModel, EmailStr


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class RegisterIn(BaseModel):
    email: EmailStr
    password: str
    role: str | None = None


class LoginIn(BaseModel):
    email: EmailStr
    password: str
