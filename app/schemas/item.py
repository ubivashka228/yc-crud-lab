import uuid
from pydantic import BaseModel


class ItemCreate(BaseModel):
    title: str
    description: str | None = None
    file_key: str | None = None


class ItemUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    file_key: str | None = None


class ItemOut(BaseModel):
    id: uuid.UUID
    title: str
    description: str | None
    owner_id: uuid.UUID
    file_key: str | None

    model_config = {"from_attributes": True}
