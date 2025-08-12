FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Bring entire build context; supports both repo root and services/ contexts
COPY . /src

# Resolve requirements path for either context
RUN set -eux; \
    if [ -f /src/recipes-api/requirements.txt ]; then \
        cp /src/recipes-api/requirements.txt /tmp/requirements.txt; \
    elif [ -f /src/services/recipes-api/requirements.txt ]; then \
        cp /src/services/recipes-api/requirements.txt /tmp/requirements.txt; \
    else \
        echo "requirements.txt not found in recipes-api" >&2; \
        ls -laR /src >&2; \
        exit 1; \
    fi; \
    pip install --no-cache-dir -r /tmp/requirements.txt

# Copy app sources (either context layout)
RUN set -eux; \
    if [ -d /src/recipes-api/app ]; then \
        cp -r /src/recipes-api/app /app/app; \
    elif [ -d /src/services/recipes-api/app ]; then \
        cp -r /src/services/recipes-api/app /app/app; \
    else \
        echo "app directory not found in recipes-api" >&2; \
        ls -laR /src >&2; \
        exit 1; \
    fi

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]