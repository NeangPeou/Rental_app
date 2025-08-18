from fastapi import FastAPI
from api.v1.routes import auth, user
from db.session import engine, Base
from fastapi.middleware.cors import CORSMiddleware
from middleware.convert_snake_to_camel import ConvertSnakeToCamelMiddleware

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add snake_case to camelCase middleware
app.add_middleware(ConvertSnakeToCamelMiddleware)

app.include_router(auth.router, prefix="/api", tags=["Auth"])
app.include_router(user.router, prefix="/api", tags=["User"])