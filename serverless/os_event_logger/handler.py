import json
import logging
from typing import Any

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event: Any, context: Any):
    # event от триггера обычно вида {"messages":[{"details":{"bucket_id":...,"object_id":...}, ...}]}
    try:
        logger.info("raw_event=%s", json.dumps(event, ensure_ascii=False))
    except Exception:
        logger.info("raw_event_unserializable=%r", event)

    messages = []
    if isinstance(event, dict) and isinstance(event.get("messages"), list):
        messages = event["messages"]

    for i, msg in enumerate(messages):
        details = (msg or {}).get("details") or {}
        bucket_id = details.get("bucket_id")
        object_id = details.get("object_id")
        logger.info("msg[%s]: bucket_id=%s object_id=%s", i, bucket_id, object_id)

    return {"statusCode": 200, "body": "ok"}
