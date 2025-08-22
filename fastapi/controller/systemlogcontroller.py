from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session
from db.models import system_log, user, role
from sqlalchemy import desc, asc

def get_system_logs_controller(db: Session, current_user: user.User = None):
    try:
        if current_user is not None:
            admin_role = db.query(role.Role).filter(role.Role.role == "Admin").first()
            if not admin_role:
                raise HTTPException(status_code=403, detail="Only admins can access system logs")
            
        # count logs
        total_logs = db.query(system_log.SystemLog).count()
        if total_logs >= 100:
            old_logs = db.query(system_log.SystemLog).order_by(asc(system_log.SystemLog.created_at)).limit(50).all()
            for log in old_logs:
                db.delete(log)
            db.commit()

        logs = db.query(system_log.SystemLog).order_by(desc(system_log.SystemLog.created_at)).all()
        return [
            {
                'id': str(log.id),
                'user_id': str(log.user_id),
                'action': log.action,
                'logType': log.logType,
                'message': log.message,
                'hostName': log.hostName,
                'created_at': log.created_at.strftime("%d/%m/%Y %I:%M %p") if log.created_at else None,
                'updated_at': log.updated_at.strftime("%d/%m/%Y %I:%M %p") if log.updated_at else None

            } for log in logs
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch system logs: {str(e)}")