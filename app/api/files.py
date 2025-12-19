from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from app.api.deps import get_current_user
from app.services.storage import S3Storage

router = APIRouter(prefix="/files", tags=["files"])


@router.post("/upload")
async def upload(file: UploadFile = File(...), _user=Depends(get_current_user)):
    storage = S3Storage()
    if not file.filename:
        raise HTTPException(status_code=400, detail="Filename is required")

    key = storage.build_key(file.filename)
    storage.upload_fileobj(file.file, key=key, content_type=file.content_type)

    return {
        "key": key,
        "public_url": storage.public_url(key),
    }


@router.get("/{key:path}/url")
async def get_presigned_url(key: str, _user=Depends(get_current_user)):
    storage = S3Storage()
    return {"url": storage.presign_get_url(key, expires_seconds=600)}
