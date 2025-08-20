import socket
from sqlalchemy.orm import Session
from db.models import system_log
from fastapi import WebSocket
from typing import List

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
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            await connection.send_text(message)
