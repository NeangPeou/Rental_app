import socket
from sqlalchemy.orm import Session
from db.models import system_log

def log_action(
    db: Session, 
    user_id: int, 
    action: str, 
    log_type: str, 
    message: str, 
    host_name: str = None, 
):
    hostname = host_name or socket.gethostname()
    log = system_log.SystemLog(
        user_id=user_id,
        action=action,
        logType=log_type,
        message=message,
        hostName=hostname,
    )
    try:
        db.add(log)
        db.commit()
    except Exception as e:
        db.rollback()
        raise e
