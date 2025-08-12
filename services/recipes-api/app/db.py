import os
from typing import Generator
from sqlmodel import SQLModel, create_engine, Session
from sqlalchemy import text

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+psycopg://zammad:zammad@postgres:5432/zammad_production")
SCHEMA_NAME = os.getenv("DB_SCHEMA", "recipes")

_engine = None


def get_engine():
    global _engine
    if _engine is None:
        # Ensure search_path to dedicated schema
        _engine = create_engine(
            DATABASE_URL,
            connect_args={"options": f"-csearch_path={SCHEMA_NAME},public"},
            pool_pre_ping=True,
        )
    return _engine


def init_engine_and_schema() -> None:
    engine = get_engine()
    with engine.connect() as conn:
        conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA_NAME}"))
        conn.commit()
    # Import models to register tables
    from . import models  # noqa: F401
    SQLModel.metadata.create_all(engine)


def get_session() -> Generator[Session, None, None]:
    with Session(get_engine()) as session:
        yield session