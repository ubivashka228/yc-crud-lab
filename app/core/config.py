from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_ignore_empty=True, extra="ignore")

    APP_NAME: str = "crud-backend"
    ENV: str = "local"
    API_PREFIX: str = "/api"

    DATABASE_URL: str

    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24

    CORS_ORIGINS: str = ""

    S3_ENDPOINT_URL: str = "https://storage.yandexcloud.net"
    S3_REGION: str = "ru-central1"
    S3_BUCKET: str = ""
    S3_ACCESS_KEY_ID: str = ""
    S3_SECRET_ACCESS_KEY: str = ""
    S3_PUBLIC_BASE_URL: str = ""

    BOOTSTRAP_ADMIN_TOKEN: str = ""

    def cors_origin_list(self) -> List[str]:
        if not self.CORS_ORIGINS.strip():
            return []
        return [o.strip() for o in self.CORS_ORIGINS.split(",") if o.strip()]


settings = Settings()
