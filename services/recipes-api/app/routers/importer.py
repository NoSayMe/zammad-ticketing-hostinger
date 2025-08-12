from typing import Dict, Any
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlmodel import Session
from ..db import get_session
from ..models import Recipe, Ingredient
import xmltodict

router = APIRouter()


def _normalize_unit(jm: str) -> str:
    jm = (jm or "").strip().upper()
    if jm == "KG":
        return "kg"
    if jm == "LT":
        return "l"
    if jm == "KS":
        return "pcs"
    return "pcs"


@router.post("/bluegastro")
async def import_bluegastro(*, file: UploadFile = File(...), session: Session = Depends(get_session)) -> Dict[str, Any]:
    if not file.filename.endswith(".xml"):
        raise HTTPException(status_code=400, detail="Expected an XML file")
    content = await file.read()
    data = xmltodict.parse(content)

    root = data.get("tjs:tovarJedlo") or data.get("tovarJedlo") or {}

    # 1) Categories
    category_map: Dict[str, Dict[str, Any]] = {}
    cat_section = root.get("ciselnikDruhTovarJedlo", {}).get("druhTovarJedlo", [])
    if isinstance(cat_section, dict):
        cat_section = [cat_section]
    for entry in cat_section:
        typ = entry.get("@typ")
        code = str(entry.get("cislo")) if entry.get("cislo") is not None else None
        name = entry.get("nazov")
        if code:
            category_map[code] = {"name": name, "typ": typ}

    # 2) Tovary map
    tovar_map: Dict[str, Dict[str, Any]] = {}
    tovary = root.get("ciselnikTovary", {}).get("tovar", [])
    if isinstance(tovary, dict):
        tovary = [tovary]
    for t in tovary:
        tid = str(t.get("@id")) if t.get("@id") is not None else None
        if not tid:
            continue
        tovar_map[tid] = {
            "name": t.get("nazov"),
            "jm": t.get("@jm"),
            "druhCislo": str(t.get("@druhCislo")) if t.get("@druhCislo") is not None else None,
        }

    # 3) Recipes
    created_recipes = 0
    created_ingredients = 0

    jedla = root.get("cislenikJedla", {}).get("jedlo", [])
    if isinstance(jedla, dict):
        jedla = [jedla]

    for j in jedla:
        receptura = j.get("receptura", {})
        polozky = receptura.get("polozkaRecept") if receptura else None
        if not polozky:
            continue  # skip recipes without receptura
        if isinstance(polozky, dict):
            polozky = [polozky]

        name = j.get("nazov") or ""
        category_code = str(j.get("@druhCislo")) if j.get("@druhCislo") is not None else None
        category = category_map.get(category_code, {}).get("name") if category_code else None
        category = category or "Nezaradené"
        base_portions = int(j.get("@pocetPorcii") or 10)
        notes = "".join([
            s for s in [j.get("popis"), j.get("popis2"), j.get("poznamka")] if s
        ]) or None

        recipe = Recipe(name=name, category=category, base_portions=base_portions, notes=notes)
        session.add(recipe)
        session.flush()
        created_recipes += 1

        for p in polozky:
            t_id = str(p.get("@idSurovina")) if p.get("@idSurovina") is not None else None
            if not t_id or t_id not in tovar_map:
                continue
            t = tovar_map[t_id]
            unit = _normalize_unit(t.get("jm"))
            raw = float(p.get("@cisteMnozstvo") or 0)
            if unit in ("kg", "l"):
                qpp = (raw / base_portions) / 1000.0
            else:  # pcs
                qpp = (raw / base_portions)
            ingredient = Ingredient(
                recipe_id=recipe.id,
                name=t.get("name") or "",
                unit=unit,
                unit_cost_eur=0.0,
                qpp=qpp,
            )
            session.add(ingredient)
            created_ingredients += 1

    session.commit()

    return {"createdRecipes": created_recipes, "createdIngredients": created_ingredients}