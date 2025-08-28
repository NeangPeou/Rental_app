from fastapi import FastAPI
from api.v1.routes import auth, user, systemlog, type
from db.models import (user as users, role, user_session, system_log, property_types, properties, units, renters, leases, payments, maintenance_requests, documents, messages)
from db.session import engine, Base
from fastapi.middleware.cors import CORSMiddleware
# from middleware.convert_snake_to_camel import ConvertSnakeToCamelMiddleware
import os
from sqlalchemy import create_engine, text

app = FastAPI()

Base.metadata.create_all(bind=engine)
#Fix database schema manually
def add_columns():
    DATABASE_URL = os.getenv("DATABASE_URL")
    engine = create_engine(DATABASE_URL)

    with engine.connect() as conn:
        #Add 'address' column only if it does not exist
        conn.execute(text("""
        DO $$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM information_schema.columns
                WHERE table_name = 't_users' AND column_name = 'address'
            ) THEN
                ALTER TABLE t_users ADD COLUMN address TEXT NOT NULL DEFAULT '';
            END IF;
                          
            IF NOT EXISTS (
                SELECT 1 FROM information_schema.columns
                WHERE table_name = 't_users' AND column_name = 'gender'
            ) THEN
                ALTER TABLE t_users ADD COLUMN gender VARCHAR(10) NOT NULL DEFAULT 'Male';
            END IF;
        END
        $$;
        """))
        conn.commit()

def drop_columns():
    DATABASE_URL = os.getenv("DATABASE_URL")
    engine = create_engine(DATABASE_URL)

    with engine.connect() as conn:
        conn.execute(text("""
        DO $$
        BEGIN
            IF EXISTS (
                SELECT 1 FROM information_schema.columns
                WHERE table_name = 't_users' AND column_name = 'addresss'
            ) THEN
                ALTER TABLE t_users DROP COLUMN addresss;
            END IF;    
        END
        $$;
        """))
        conn.commit()

# add_columns()
# drop_columns()

app.add_middleware(
    CORSMiddleware,
    allow_origins = ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add snake_case to camelCase middleware
# app.add_middleware(ConvertSnakeToCamelMiddleware)

app.include_router(auth.router, prefix="/api", tags=["Auth"])
app.include_router(user.router, prefix="/api", tags=["User"])
app.include_router(systemlog.router, prefix="/api", tags=["SystemLog"])
app.include_router(type.router, prefix="/api", tags=["Type"])