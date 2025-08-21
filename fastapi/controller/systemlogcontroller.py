from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session
from db.models import system_log, user, role
from controller.usercontroller import get_current_user
from sqlalchemy import desc

def get_system_logs_controller(db: Session, current_user: user.User = Depends(get_current_user)):
    try:
        admin_role = db.query(role.Role).filter(role.Role.role == "Admin").first()
        if not admin_role:
            raise HTTPException(status_code=403, detail="Only admins can access system logs")

        logs = db.query(system_log.SystemLog).order_by(desc(system_log.SystemLog.created_at)).all()
        return [
            {
                'id': str(log.id),
                'user_id': str(log.user_id),
                'action': log.action,
                'logType': log.logType,
                'message': log.message,
                'hostName': log.hostName,
                'created_at': log.created_at.isoformat() if log.created_at else None,
                'updated_at': log.updated_at.isoformat() if log.updated_at else None
            } for log in logs
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch system logs: {str(e)}")