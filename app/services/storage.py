import uuid

import boto3
from botocore.client import Config

from app.core.config import settings


class S3Storage:
    def __init__(self) -> None:
        self._client = boto3.client(
            "s3",
            endpoint_url=settings.S3_ENDPOINT_URL,
            region_name=settings.S3_REGION,
            aws_access_key_id=settings.S3_ACCESS_KEY_ID or None,
            aws_secret_access_key=settings.S3_SECRET_ACCESS_KEY or None,
            config=Config(signature_version="s3v4"),
        )

    @property
    def bucket(self) -> str:
        if not settings.S3_BUCKET:
            raise RuntimeError("S3_BUCKET is not set")
        return settings.S3_BUCKET

    def build_key(self, filename: str) -> str:
        return f"attachments/{uuid.uuid4()}/{filename}"

    def upload_fileobj(self, fileobj, key: str, content_type: str | None = None) -> None:
        extra = {}
        if content_type:
            extra["ContentType"] = content_type
        self._client.upload_fileobj(fileobj, self.bucket, key, ExtraArgs=extra or None)

    def delete(self, key: str) -> None:
        self._client.delete_object(Bucket=self.bucket, Key=key)

    def presign_get_url(self, key: str, expires_seconds: int = 600) -> str:
        return self._client.generate_presigned_url(
            "get_object",
            Params={"Bucket": self.bucket, "Key": key},
            ExpiresIn=expires_seconds,
        )

    def public_url(self, key: str) -> str | None:
        if not settings.S3_PUBLIC_BASE_URL:
            return None
        base = settings.S3_PUBLIC_BASE_URL.rstrip("/")
        return f"{base}/{key}"
