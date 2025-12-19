import uuid
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.item import Item


async def create_item(db: AsyncSession, owner_id: uuid.UUID, title: str, description: str | None, file_key: str | None) -> Item:
    item = Item(owner_id=owner_id, title=title, description=description, file_key=file_key)
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item


async def get_item(db: AsyncSession, item_id: uuid.UUID) -> Item | None:
    res = await db.execute(select(Item).where(Item.id == item_id))
    return res.scalar_one_or_none()


async def list_items(db: AsyncSession, limit: int = 50, offset: int = 0) -> list[Item]:
    res = await db.execute(select(Item).order_by(Item.created_at.desc()).limit(limit).offset(offset))
    return list(res.scalars().all())


async def update_item(db: AsyncSession, item: Item) -> Item:
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item


async def delete_item(db: AsyncSession, item: Item) -> None:
    await db.delete(item)
    await db.commit()
