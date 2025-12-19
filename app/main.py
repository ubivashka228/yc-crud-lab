from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api.router import router as router

app = FastAPI(title=settings.APP_NAME)

origins = settings.cors_origin_list()
if origins:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(router, prefix=settings.API_PREFIX)


@app.get("/health")
async def health():
    return {"status": "ok"}
