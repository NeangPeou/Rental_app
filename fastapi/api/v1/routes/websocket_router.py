from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from helper.hepler import ConnectionManager

ws_router = APIRouter()
manager = ConnectionManager()

@ws_router.websocket("/ws/owners")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)
