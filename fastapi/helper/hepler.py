import socket
from sqlalchemy.orm import Session
from db.models import system_log

def log_action(db: Session, user_id: int, action: str, log_type: str, message: str, old_data: str = None, new_data: str = None):
    hostname = socket.gethostname()
    log = system_log.SystemLog(
        user_id=user_id,
        action=action,
        oldData=old_data,
        newData=new_data,
        logType=log_type,
        message=message,
        hostName=hostname,
    )
    db.add(log)
    db.commit()
