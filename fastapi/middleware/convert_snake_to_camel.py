import json
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

class ConvertSnakeToCamelMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        if request.method == "POST":
            try:
                body = await request.json()
                converted_body = {}
                for key, value in body.items():
                    if key == "device_name":
                        converted_body["deviceName"] = value
                    elif key == "user_agent":
                        converted_body["userAgent"] = value
                    else:
                        converted_body[key] = value
                request._body = json.dumps(converted_body).encode("utf-8")
            except json.JSONDecodeError:
                pass
        return await call_next(request)