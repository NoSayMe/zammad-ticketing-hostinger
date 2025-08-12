### Recipe Manager (MVP)

A lightweight, containerized app to manage recipes for restaurant operations. Ships as two services: `recipes-api` (FastAPI) and `recipes-frontend` (React + Vite), proxied by existing `nginx`.

- Backend: FastAPI + SQLModel, Uvicorn
- DB: PostgreSQL (reuses existing DB via dedicated schema `recipes`)
- Frontend: React (Vite, TypeScript), Tailwind, print CSS
- Reverse proxy: existing `nginx`

#### Data model
- `recipes(id uuid, name text, category text, base_portions int, notes text)`
- `ingredients(id uuid, recipe_id uuid fk, name text, unit text, unit_cost_eur numeric, qpp numeric)`

Units are normalized: `kg`, `l`, `pcs`. QPP = quantity per portion in normalized unit.

Cost/portion = Σ(qpp × unit_cost_eur). Scaling multiplies qpp by target portions.

#### API
Base: `/recipes-api`

- GET `/recipes`
- POST `/recipes`
- GET `/recipes/{id}`
- PUT `/recipes/{id}`
- DELETE `/recipes/{id}`
- POST `/recipes/{id}/ingredients`
- PUT `/recipes/{id}/ingredients/{iid}`
- DELETE `/recipes/{id}/ingredients/{iid}`
- GET `/recipes/{id}/scale?portions=P`
- POST `/import/bluegastro` (multipart XML)

#### BlueGastro XML import
- Builds category and ingredients catalogs from XML
- Imports ~780 recipes and ~390-400 ingredients
- Normalizes qpp per rules: KG/LT → divide by 1000 and basePortions; KS → divide by basePortions
- `unit_cost_eur` defaults to 0 and can be edited later

Upload via POST `/recipes-api/import/bluegastro` with `file` field.

#### Compose integration
Two new services are added and proxied by `nginx`:
- `recipes-api` → `/recipes-api/`
- `recipes-frontend` → `/recipes/`

Both join the existing `zammad-net`.

#### Environment
- `RECIPES_DATABASE_URL` (optional): overrides DB connection string (SQLAlchemy/psycopg). Defaults to existing Postgres in compose
- `DB_SCHEMA` (optional): Postgres schema, default `recipes`

By default the API connects to `${POSTGRES_DB}` and creates schema `recipes` on startup. No Alembic in MVP; tables are auto-created.

#### Frontend
- Vite base is `/recipes/`
- `VITE_API_BASE` can override API base (default `/recipes-api`)
- Features:
  - List recipes (search)
  - Create/edit recipe (name, category, basePortions, notes)
  - Ingredients grid (name, unit, unit cost, QPP)
  - Live cost/portion and suggested prices (55/60/65%)
  - Scaling view for arbitrary portions
  - Print view (A4-friendly)

#### Deployment
- Build via compose (root `docker-compose.yaml`)
- Access app at `https://<domain>/recipes/`
- API at `https://<domain>/recipes-api/`

#### Notes
- Recipes with non-PO output units are treated the same; wording remains “portions” in UI
- Duplicates allowed; app uses UUIDs
- Missing `receptura` in XML are skipped