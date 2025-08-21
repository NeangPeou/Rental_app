import json
import socket
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session
from db.models import system_log
from fastapi import WebSocket
from typing import Dict, List

def log_action(db: Session, user_id: int, action: str, log_type: str, message: str, host_name: str = None):
    hostname = host_name or socket.gethostname()
    log = system_log.SystemLog(user_id=user_id, action=action, logType=log_type, message=message, hostName=hostname)
    try:
        db.add(log)
        db.commit()
    except Exception as e:
        db.rollback()
        raise e

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, channel: str):
        await websocket.accept()
        if channel not in self.active_connections:
            self.active_connections[channel] = []
        self.active_connections[channel].append(websocket)

    def disconnect(self, websocket: WebSocket, channel: str):
        if channel in self.active_connections:
            self.active_connections[channel].remove(websocket)

    async def broadcast(self, message: dict, channel: str):
        text = json.dumps(jsonable_encoder(message))
        for connection in self.active_connections.get(channel, []):
            await connection.send_text(text)

manager = ConnectionManager()
