from fastapi import APIRouter, HTTPException, Header
import os
from supabase_client import get_supabase

router = APIRouter(prefix="/suggestions", tags=["suggestions"])


def _check_token(token: str):
    if token != f"Bearer {os.getenv('SECRET_TOKEN')}":
        raise HTTPException(status_code=401, detail="Non autorisé")


@router.get("/{user_id}")
async def get_suggestions(
    user_id: str,
    authorization: str = Header(default=""),
):
    """
    Suggestions personnalisées basées sur l'historique client.
    Retourne les partenaires les plus commandés + nouveaux proches.
    """
    _check_token(authorization)
    sb = get_supabase()

    # Top partenaires du client
    orders = sb.table("orders") \
        .select("partner_id, partners(business_name, image_url, rating)") \
        .eq("client_id", user_id) \
        .eq("status", "delivered") \
        .order("created_at", desc=True) \
        .limit(20) \
        .execute()

    # Compter les commandes par partenaire
    partner_counts: dict = {}
    for order in (orders.data or []):
        pid = order["partner_id"]
        partner_counts[pid] = partner_counts.get(pid, 0) + 1

    # Trier par fréquence
    sorted_partners = sorted(
        partner_counts.items(),
        key=lambda x: x[1],
        reverse=True,
    )[:5]

    suggestions = []
    for partner_id, count in sorted_partners:
        partner_data = next(
            (o["partners"] for o in orders.data if o["partner_id"] == partner_id),
            None,
        )
        if partner_data:
            suggestions.append({
                "type": "reorder",
                "partner_id": partner_id,
                "title": f"Recommander chez {partner_data['business_name']}",
                "subtitle": f"Commandé {count} fois",
                "data": partner_data,
            })

    return {"suggestions": suggestions}