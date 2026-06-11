from fastapi import APIRouter, Header, HTTPException
from pydantic import BaseModel
from typing import Optional
import os
from services.chat_service import chat_with_ai
from services.recommendation_service import get_promotions_nearby
from supabase_client import get_supabase

router = APIRouter(prefix="/chat", tags=["chat"])


def _check_token(token: str):
    if token != f"Bearer {os.getenv('SECRET_TOKEN')}":
        raise HTTPException(status_code=401, detail="Non autorisé")


class ChatRequest(BaseModel):
    client_id: str
    message: str
    conversation_id: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None


@router.post("/message")
async def send_message(
    body: ChatRequest,
    authorization: str = Header(default=""),
):
    """Envoie un message à l'assistant HOLLA et retourne la réponse IA."""
    _check_token(authorization)
    sb = get_supabase()

    # Charger ou créer la conversation
    if body.conversation_id:
        conv = sb.table("ai_conversations") \
            .select("*") \
            .eq("id", body.conversation_id) \
            .single() \
            .execute()
        history = conv.data.get("messages", []) if conv.data else []
    else:
        history = []

    # Construire le contexte dynamique
    context = {}

    # Commandes actives du client
    active_orders = sb.table("orders") \
        .select("id, status, partners(business_name)") \
        .eq("client_id", body.client_id) \
        .in_("status", ["pending", "confirmed", "preparing", "in_delivery"]) \
        .execute()

    if active_orders.data:
        context["active_orders"] = [
            {
                "id":           o["id"],
                "status":       o["status"],
                "partner_name": o["partners"]["business_name"],
            }
            for o in active_orders.data
        ]

    # Offres du jour si coords disponibles
    if body.lat and body.lng:
        promos = get_promotions_nearby(body.lat, body.lng)
        if promos:
            context["promotions"] = promos[:5]

        # Top partenaires proches
        partners = sb.table("partners") \
            .select("business_name, business_type, rating, delivery_time") \
            .eq("is_open", True) \
            .eq("is_verified", True) \
            .order("rating", desc=True) \
            .limit(5) \
            .execute()
        if partners.data:
            context["top_partners"] = partners.data

    # Appel IA
    ai_response = await chat_with_ai(
        message=body.message,
        conversation_history=history,
        context=context,
    )

    # Sauvegarder la conversation
    history.append({"role": "user",      "content": body.message})
    history.append({"role": "assistant", "content": ai_response})

    if body.conversation_id:
        sb.table("ai_conversations") \
            .update({"messages": history}) \
            .eq("id", body.conversation_id) \
            .execute()
        conv_id = body.conversation_id
    else:
        new_conv = sb.table("ai_conversations") \
            .insert({
                "client_id": body.client_id,
                "messages":  history,
                "context":   "support",
            }) \
            .execute()
        conv_id = new_conv.data[0]["id"]

    return {
        "response":        ai_response,
        "conversation_id": conv_id,
    }