from fastapi import APIRouter, HTTPException, Header
from pydantic import BaseModel
from typing import Optional
import os
from services.assignment_service import assign_best_agent
from supabase_client import get_supabase

router = APIRouter(prefix="/delivery", tags=["delivery"])


def _check_token(token: str):
    if token != f"Bearer {os.getenv('SECRET_TOKEN')}":
        raise HTTPException(status_code=401, detail="Non autorisé")


class AssignRequest(BaseModel):
    order_id: str
    delivery_lat: float
    delivery_lng: float
    partner_lat: float
    partner_lng: float


class LocationUpdate(BaseModel):
    agent_id: str
    latitude: float
    longitude: float


@router.post("/assign")
async def assign_delivery(
    body: AssignRequest,
    authorization: str = Header(default=""),
):
    """Affecte le meilleur livreur disponible à une commande."""
    _check_token(authorization)

    agent = assign_best_agent(
        delivery_lat=body.delivery_lat,
        delivery_lng=body.delivery_lng,
        partner_lat=body.partner_lat,
        partner_lng=body.partner_lng,
    )

    if not agent:
        return {"assigned": False, "message": "Aucun livreur disponible"}

    sb = get_supabase()

    # Assigner le livreur à la commande
    sb.table("orders").update({
        "delivery_agent_id": agent["id"],
        "status": "confirmed",
    }).eq("id", body.order_id).execute()

    # Marquer le livreur comme occupé
    sb.table("delivery_agents").update({
        "is_available": False,
    }).eq("id", agent["id"]).execute()

    return {
        "assigned": True,
        "agent_id": agent["id"],
        "agent_name": agent.get("profiles", {}).get("name"),
        "distance_km": round(agent["_dist"], 2),
        "score": round(agent["_score"], 3),
    }


@router.put("/location")
async def update_location(
    body: LocationUpdate,
    authorization: str = Header(default=""),
):
    """Met à jour la position GPS d'un livreur — appelé depuis l'app livreur."""
    _check_token(authorization)

    sb = get_supabase()
    sb.table("delivery_agents").update({
        "latitude":  body.latitude,
        "longitude": body.longitude,
    }).eq("id", body.agent_id).execute()

    return {"updated": True}