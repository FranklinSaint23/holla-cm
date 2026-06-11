from fastapi import APIRouter, Header, HTTPException
from pydantic import BaseModel
from typing import Optional
import os
from services.recommendation_service import (
    get_promotions_nearby,
    get_personalized_feed,
)

router = APIRouter(prefix="/promotions", tags=["promotions"])


def _check_token(token: str):
    if token != f"Bearer {os.getenv('SECRET_TOKEN')}":
        raise HTTPException(status_code=401, detail="Non autorisé")


@router.get("/nearby")
async def nearby_promos(
    lat: float,
    lng: float,
    radius: float = 10,
    authorization: str = Header(default=""),
):
    """Retourne les offres du jour dans un rayon donné."""
    _check_token(authorization)
    promos = get_promotions_nearby(lat, lng, radius)
    return {"promotions": promos, "count": len(promos)}


@router.get("/feed/{client_id}")
async def personalized_feed(
    client_id: str,
    lat: float,
    lng: float,
    authorization: str = Header(default=""),
):
    """Feed personnalisé pour la home screen."""
    _check_token(authorization)
    feed = get_personalized_feed(client_id, lat, lng)
    return feed