from fastapi import APIRouter

from app.api import files, requests

router = APIRouter()
router.include_router(requests.router)
router.include_router(files.router)
