import uuid
from pydantic import BaseModel, EmailStr


class UserOut(BaseModel):
    id: uuid.UUID
    email: EmailStr
    role: str

    model_config = {"from_attributes": True}
