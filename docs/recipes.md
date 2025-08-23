[← Back to Main README](README/index.md)

# Recipe Manager (MVP)

A lightweight, containerized app to manage recipes for restaurant operations. It ships as two services: `recipes-api` (FastAPI) and `recipes-frontend` (React + Vite), both proxied by the main `nginx` reverse proxy.

## Data model

- `recipes(id uuid, name text, category text, base_portions int, notes text)`
- `ingredients(id uuid, recipe_id uuid fk, name text, unit text, unit_cost_eur numeric, qpp numeric)`

Units are normalized: `kg`, `l`, `pcs`. QPP = quantity per portion in normalized unit. Cost/portion is the sum of `qpp × unit_cost_eur`.

## API

Base path: `/recipes-api`

- `GET /recipes`
- `POST /recipes`
- `GET /recipes/{id}`
- `PUT /recipes/{id}`
- `DELETE /recipes/{id}`
- `POST /recipes/{id}/ingredients`
- `PUT /recipes/{id}/ingredients/{iid}`
- `DELETE /recipes/{id}/ingredients/{iid}`
- `GET /recipes/{id}/scale?portions=P`
- `POST /import/bluegastro` (multipart XML)

## Compose integration

Two services join the existing `zammad-net` and are routed through NGINX:

- `recipes-api` → `/recipes-api/`
- `recipes-frontend` → `/recipes/`

The API connects to the main Postgres database and creates a dedicated `recipes` schema on startup.

## Deployment

- Build via root `docker-compose.yaml`.
- Access frontend at `https://<domain>/recipes/`.
- API at `https://<domain>/recipes-api/`.

## Troubleshooting

- If `/recipes/` returns `502 Bad Gateway`, ensure NGINX uses a fixed upstream name:

  ```nginx
  location /recipes/ {
      proxy_pass http://recipes-frontend/recipes/;
  }
  ```

---
🔗 Back to [Main README](README/index.md)
📚 See also: [Deployment](deployment.md) | [CI/CD](ci-cd-pipeline.md) | [Secrets](secrets.md)

