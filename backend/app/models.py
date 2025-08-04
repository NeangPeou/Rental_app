from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Float
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

class Role(Base):
    __tablename__ = "t_roles"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True)

    users = relationship("User", back_populates="role")

class User(Base):
    __tablename__ = "t_users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    password = Column(String)
    code = Column(String, nullable=True)   # for rental login
    role_id = Column(Integer, ForeignKey("t_roles.id"))
    is_active = Column(Boolean, default=True)

    role = relationship("Role", back_populates="users")
    sessions = relationship("UserSession", back_populates="user")

class UserSession(Base):
    __tablename__ = "t_users_session"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("t_users.id"))
    token = Column(String, unique=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    expired_at = Column(DateTime)

    user = relationship("User", back_populates="sessions")

class SystemLog(Base):
    __tablename__ = "t_system_log"
    id = Column(Integer, primary_key=True, index=True)
    action = Column(String)
    user_id = Column(Integer, ForeignKey("t_users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)
