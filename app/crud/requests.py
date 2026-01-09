import uuid
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.request import Request


async def create_request(
    db: AsyncSession,
    subject: str,
    body: str | None,
    status: str,
    attachment_key: str | None,
) -> Request:
    obj = Request(
        subject=subject,
        body=body,
        status=status,
        attachment_key=attachment_key,
    )
    db.add(obj)
    await db.commit()
    await db.refresh(obj)
    return obj


async def list_requests(db: AsyncSession, limit: int = 50, offset: int = 0) -> list[Request]:
    stmt = select(Request).offset(offset).limit(limit)
    res = await db.execute(stmt)
    return list(res.scalars().all())


async def get_request(db: AsyncSession, request_id: uuid.UUID) -> Request | None:
    stmt = select(Request).where(Request.id == request_id)
    res = await db.execute(stmt)
    return res.scalar_one_or_none()


async def update_request(db: AsyncSession, obj: Request) -> Request:
    db.add(obj)
    await db.commit()
    await db.refresh(obj)
    return obj


async def delete_request(db: AsyncSession, obj: Request) -> None:
    await db.delete(obj)
    await db.commit()
