from fastapi import APIRouter, Depends, HTTPException, status, Header
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.core.config import settings
from app.core.security import create_access_token
from app.crud.users import create_user, get_by_email, check_password
from app.schemas.auth import Token, RegisterIn, LoginIn
from app.schemas.user import UserOut

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=UserOut)
async def register(
    payload: RegisterIn,
    db: AsyncSession = Depends(get_db),
    x_bootstrap_token: str | None = Header(default=None, alias="X-Bootstrap-Token"),
):
    existing = await get_by_email(db, payload.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    role = "user"
    if payload.role:
        if not settings.BOOTSTRAP_ADMIN_TOKEN or x_bootstrap_token != settings.BOOTSTRAP_ADMIN_TOKEN:
            raise HTTPException(status_code=403, detail="Role assignment forbidden")
        if payload.role not in ("user", "admin"):
            raise HTTPException(status_code=400, detail="Invalid role")
        role = payload.role

    user = await create_user(db, payload.email, payload.password, role=role)
    return user


@router.post("/login", response_model=Token)
async def login(payload: LoginIn, db: AsyncSession = Depends(get_db)):
    user = await get_by_email(db, payload.email)
    if not user or not check_password(user, payload.password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    token = create_access_token(subject=user.email)
    return Token(access_token=token)


@router.get("/me", response_model=UserOut)
async def me(user=Depends(get_current_user)):
    return user
