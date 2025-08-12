from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import select
from sqlmodel import Session
from ..db import get_session
from ..models import Recipe, RecipeCreate, RecipeRead, RecipeUpdate, Ingredient, IngredientCreate, IngredientRead, IngredientUpdate

router = APIRouter()


@router.get("", response_model=List[RecipeRead])
def list_recipes(*, session: Session = Depends(get_session)) -> List[RecipeRead]:
    recipes = session.exec(select(Recipe)).all()
    for r in recipes:
        _ = r.ingredients
    return recipes


@router.post("", response_model=RecipeRead)
def create_recipe(*, payload: RecipeCreate, session: Session = Depends(get_session)) -> RecipeRead:
    recipe = Recipe(name=payload.name, category=payload.category, base_portions=payload.base_portions, notes=payload.notes)
    session.add(recipe)
    session.flush()
    if payload.ingredients:
        for ing in payload.ingredients:
            ingredient = Ingredient(
                recipe_id=recipe.id,
                name=ing.name,
                unit=ing.unit,
                unit_cost_eur=ing.unit_cost_eur,
                qpp=ing.qpp,
            )
            session.add(ingredient)
    session.commit()
    session.refresh(recipe)
    return recipe


@router.get("/{recipe_id}", response_model=RecipeRead)
def get_recipe(*, recipe_id: str, session: Session = Depends(get_session)) -> RecipeRead:
    recipe = session.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    _ = recipe.ingredients
    return recipe


@router.put("/{recipe_id}", response_model=RecipeRead)
def update_recipe(*, recipe_id: str, payload: RecipeUpdate, session: Session = Depends(get_session)) -> RecipeRead:
    recipe = session.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    data = payload.dict(exclude_unset=True)
    for key, value in data.items():
        setattr(recipe, key, value)
    session.add(recipe)
    session.commit()
    session.refresh(recipe)
    _ = recipe.ingredients
    return recipe


@router.delete("/{recipe_id}")
def delete_recipe(*, recipe_id: str, session: Session = Depends(get_session)) -> dict:
    recipe = session.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    session.delete(recipe)
    session.commit()
    return {"ok": True}


@router.post("/{recipe_id}/ingredients", response_model=IngredientRead)
def add_ingredient(*, recipe_id: str, payload: IngredientCreate, session: Session = Depends(get_session)) -> IngredientRead:
    recipe = session.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    ingredient = Ingredient(recipe_id=recipe.id, name=payload.name, unit=payload.unit, unit_cost_eur=payload.unit_cost_eur, qpp=payload.qpp)
    session.add(ingredient)
    session.commit()
    session.refresh(ingredient)
    return ingredient


@router.put("/{recipe_id}/ingredients/{ingredient_id}", response_model=IngredientRead)
def update_ingredient(*, recipe_id: str, ingredient_id: str, payload: IngredientUpdate, session: Session = Depends(get_session)) -> IngredientRead:
    recipe = session.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    ingredient = session.get(Ingredient, ingredient_id)
    if not ingredient or ingredient.recipe_id != recipe.id:
        raise HTTPException(status_code=404, detail="Ingredient not found")
    data = payload.dict(exclude_unset=True)
    for key, value in data.items():
        setattr(ingredient, key, value)
    session.add(ingredient)
    session.commit()
    session.refresh(ingredient)
    return ingredient


@router.delete("/{recipe_id}/ingredients/{ingredient_id}")
def delete_ingredient(*, recipe_id: str, ingredient_id: str, session: Session = Depends(get_session)) -> dict:
    recipe = session.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    ingredient = session.get(Ingredient, ingredient_id)
    if not ingredient or ingredient.recipe_id != recipe.id:
        raise HTTPException(status_code=404, detail="Ingredient not found")
    session.delete(ingredient)
    session.commit()
    return {"ok": True}


@router.get("/{recipe_id}/scale")
def scale_recipe(*, recipe_id: str, portions: int = Query(..., gt=0), session: Session = Depends(get_session)) -> dict:
    recipe = session.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    _ = recipe.ingredients
    scaled_rows = []
    cost_per_portion = 0.0
    for ing in recipe.ingredients:
        scaled_qty = ing.qpp * portions
        cost_per_portion += ing.qpp * ing.unit_cost_eur
        scaled_rows.append({
            "id": str(ing.id),
            "name": ing.name,
            "unit": ing.unit,
            "unitCost": ing.unit_cost_eur,
            "qpp": ing.qpp,
            "scaledQty": scaled_qty,
        })
    total_cost = cost_per_portion * portions
    return {
        "id": str(recipe.id),
        "name": recipe.name,
        "category": recipe.category,
        "basePortions": recipe.base_portions,
        "notes": recipe.notes,
        "portions": portions,
        "ingredients": scaled_rows,
        "costPerPortion": round(cost_per_portion, 4),
        "totalCost": round(total_cost, 2),
        "suggestedPrices": {
            "55": round(cost_per_portion / (1 - 0.55), 2) if cost_per_portion > 0 else 0,
            "60": round(cost_per_portion / (1 - 0.60), 2) if cost_per_portion > 0 else 0,
            "65": round(cost_per_portion / (1 - 0.65), 2) if cost_per_portion > 0 else 0,
        }
    }