from fastapi import APIRouter, HTTPException, Header
from pydantic import BaseModel
import os
from services.prediction_service import (
    predict_delivery_time,
    get_demand_prediction,
)

router = APIRouter(prefix="/predict", tags=["prediction"])


def _check_token(token: str):
    if token != f"Bearer {os.getenv('SECRET_TOKEN')}":
        raise HTTPException(status_code=401, detail="Non autorisé")


class DeliveryTimeRequest(BaseModel):
    partner_lat: float
    partner_lng: float
    delivery_lat: float
    delivery_lng: float


@router.post("/delivery-time")
async def delivery_time(
    body: DeliveryTimeRequest,
    authorization: str = Header(default=""),
):
    """Prédit le délai de livraison en minutes."""
    _check_token(authorization)
    minutes = predict_delivery_time(
        body.partner_lat, body.partner_lng,
        body.delivery_lat, body.delivery_lng,
    )
    return {"estimated_minutes": minutes}


@router.get("/demand/{partner_id}")
async def demand_prediction(
    partner_id: str,
    authorization: str = Header(default=""),
):
    """Prédit la demande pour les 3 prochaines heures."""
    _check_token(authorization)
    return get_demand_prediction(partner_id)