from __future__ import annotations

import uuid
from typing import Literal

from pydantic import BaseModel, Field


RequestStatus = Literal["new", "in_progress", "done"]


class RequestCreate(BaseModel):
    subject: str = Field(min_length=1, max_length=200)
    body: str | None = None
    status: RequestStatus = "new"
    attachment_key: str | None = None


class RequestUpdate(BaseModel):
    subject: str | None = Field(default=None, min_length=1, max_length=200)
    body: str | None = None
    status: RequestStatus | None = None
    attachment_key: str | None = None


class RequestOut(BaseModel):
    id: uuid.UUID
    subject: str
    body: str | None = None
    status: RequestStatus
    attachment_key: str | None = None

    class Config:
        from_attributes = True
