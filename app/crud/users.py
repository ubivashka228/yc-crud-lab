from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password, verify_password
from app.models.user import User


async def get_by_email(db: AsyncSession, email: str) -> User | None:
    res = await db.execute(select(User).where(User.email == email))
    return res.scalar_one_or_none()


async def create_user(db: AsyncSession, email: str, password: str, role: str = "user") -> User:
    user = User(email=email, password_hash=hash_password(password), role=role)
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


def check_password(user: User, password: str) -> bool:
    return verify_password(password, user.password_hash)
