from fastapi import FastAPI
from api.v1.routes import auth
from db.session import engine, Base
from fastapi.middleware.cors import CORSMiddleware
from db.models import user, role, system_log, user_session

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api", tags=["Auth"])
