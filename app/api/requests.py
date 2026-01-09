import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db
from app.crud.requests import (
    create_request,
    delete_request,
    get_request,
    list_requests,
    update_request,
)
from app.schemas.request import RequestCreate, RequestOut, RequestUpdate

router = APIRouter(prefix="/requests", tags=["requests"])


@router.post("", response_model=RequestOut)
async def create(payload: RequestCreate, db: AsyncSession = Depends(get_db)):
    return await create_request(
        db,
        subject=payload.subject,
        body=payload.body,
        status=payload.status,
        attachment_key=payload.attachment_key,
    )


@router.get("", response_model=list[RequestOut])
async def list_(limit: int = 50, offset: int = 0, db: AsyncSession = Depends(get_db)):
    return await list_requests(db, limit=limit, offset=offset)


@router.get("/{request_id}", response_model=RequestOut)
async def get_(request_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    obj = await get_request(db, request_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Not found")
    return obj


@router.patch("/{request_id}", response_model=RequestOut)
async def patch(request_id: uuid.UUID, payload: RequestUpdate, db: AsyncSession = Depends(get_db)):
    obj = await get_request(db, request_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Not found")

    if payload.subject is not None:
        obj.subject = payload.subject
    if payload.body is not None:
        obj.body = payload.body
    if payload.status is not None:
        obj.status = payload.status
    if payload.attachment_key is not None:
        obj.attachment_key = payload.attachment_key

    return await update_request(db, obj)


@router.delete("/{request_id}")
async def delete_(request_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    obj = await get_request(db, request_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Not found")

    await delete_request(db, obj)
    return {"ok": True}
