import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.crud.items import create_item, delete_item, get_item, list_items, update_item
from app.schemas.item import ItemCreate, ItemOut, ItemUpdate
from app.models.user import User

router = APIRouter(prefix="/items", tags=["items"])


@router.post("", response_model=ItemOut)
async def create(payload: ItemCreate, db: AsyncSession = Depends(get_db), user: User = Depends(get_current_user)):
    return await create_item(db, owner_id=user.id, title=payload.title, description=payload.description, file_key=payload.file_key)


@router.get("", response_model=list[ItemOut])
async def list_(limit: int = 50, offset: int = 0, db: AsyncSession = Depends(get_db)):
    return await list_items(db, limit=limit, offset=offset)


@router.get("/{item_id}", response_model=ItemOut)
async def get_(item_id: uuid.UUID, db: AsyncSession = Depends(get_db)):
    item = await get_item(db, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Not found")
    return item


@router.patch("/{item_id}", response_model=ItemOut)
async def patch(
    item_id: uuid.UUID,
    payload: ItemUpdate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    item = await get_item(db, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Not found")

    if item.owner_id != user.id and user.role != "admin":
        raise HTTPException(status_code=403, detail="Forbidden")

    if payload.title is not None:
        item.title = payload.title
    if payload.description is not None:
        item.description = payload.description
    if payload.file_key is not None:
        item.file_key = payload.file_key

    return await update_item(db, item)


@router.delete("/{item_id}")
async def delete_(item_id: uuid.UUID, db: AsyncSession = Depends(get_db), user: User = Depends(get_current_user)):
    item = await get_item(db, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Not found")

    if item.owner_id != user.id and user.role != "admin":
        raise HTTPException(status_code=403, detail="Forbidden")

    await delete_item(db, item)
    return {"ok": True}
