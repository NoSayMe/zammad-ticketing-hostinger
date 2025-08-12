from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .db import init_engine_and_schema
from .routers import recipes as recipes_router
from .routers import importer as importer_router

app = FastAPI(title="Recipe Manager API", version="0.1.0")

# Allow proxy/frontend origins; in proxy we will call via same host
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize DB engine and ensure schema exists
init_engine_and_schema()

@app.get("/")
def health():
    return {"ok": True}

# Routers
app.include_router(recipes_router.router, prefix="/recipes", tags=["recipes"]) 
app.include_router(importer_router.router, prefix="/import", tags=["import"])