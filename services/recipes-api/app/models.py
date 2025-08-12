from __future__ import annotations
from typing import Optional, List
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field, Relationship
from pydantic import AliasChoices
from pydantic.config import ConfigDict


class IngredientBase(SQLModel):
    name: str
    unit: str  # 'kg' | 'l' | 'pcs'
    unit_cost_eur: float = Field(
        default=0.0,
        validation_alias=AliasChoices("unitCost", "unit_cost_eur"),
        serialization_alias="unitCost",
    )
    qpp: float  # quantity per portion (normalized)


class RecipeBase(SQLModel):
    name: str
    category: str
    base_portions: int = Field(
        validation_alias=AliasChoices("basePortions", "base_portions"),
        serialization_alias="basePortions",
    )
    notes: Optional[str] = None


class Ingredient(IngredientBase, table=True):
    __tablename__ = "ingredients"
    id: UUID = Field(default_factory=uuid4, primary_key=True, index=True)
    recipe_id: UUID = Field(foreign_key="recipes.id", index=True)

    recipe: Optional["Recipe"] = Relationship(back_populates="ingredients")


class Recipe(RecipeBase, table=True):
    __tablename__ = "recipes"
    id: UUID = Field(default_factory=uuid4, primary_key=True, index=True)

    ingredients: List[Ingredient] = Relationship(
        back_populates="recipe", sa_relationship_kwargs={"cascade": "all, delete-orphan"}
    )


# Read/Write schemas
class IngredientCreate(IngredientBase):
    model_config = ConfigDict(populate_by_name=True)


class IngredientRead(IngredientBase):
    model_config = ConfigDict(populate_by_name=True, from_attributes=True)
    id: UUID


class RecipeCreate(RecipeBase):
    model_config = ConfigDict(populate_by_name=True)
    ingredients: Optional[List[IngredientCreate]] = None


class RecipeRead(RecipeBase):
    model_config = ConfigDict(populate_by_name=True, from_attributes=True)
    id: UUID
    ingredients: List[IngredientRead] = []


class RecipeUpdate(SQLModel):
    name: Optional[str] = None
    category: Optional[str] = None
    base_portions: Optional[int] = Field(
        default=None,
        validation_alias=AliasChoices("basePortions", "base_portions"),
        serialization_alias="basePortions",
    )
    notes: Optional[str] = None


class IngredientUpdate(SQLModel):
    name: Optional[str] = None
    unit: Optional[str] = None
    unit_cost_eur: Optional[float] = Field(
        default=None,
        validation_alias=AliasChoices("unitCost", "unit_cost_eur"),
        serialization_alias="unitCost",
    )
    qpp: Optional[float] = None