from fastapi import APIRouter

from app.api import auth, items, files

router = APIRouter()
router.include_router(auth.router)
router.include_router(items.router)
router.include_router(files.router)
