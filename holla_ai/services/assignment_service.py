import math
from typing import Optional
from supabase_client import get_supabase


def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Distance en km entre deux coordonnées GPS."""
    R = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def assign_best_agent(
    delivery_lat: float,
    delivery_lng: float,
    partner_lat: float,
    partner_lng: float,
) -> Optional[dict]:
    """
    Algorithme d'affectation du meilleur livreur disponible.
    Score composite : 60% distance partner→livreur + 40% rating inversé.
    """
    sb = get_supabase()

    # Récupérer les livreurs disponibles
    agents = sb.table("delivery_agents") \
        .select("*, profiles(name)") \
        .eq("is_available", True) \
        .execute()

    if not agents.data:
        return None

    best = None
    best_score = float("inf")

    for agent in agents.data:
        if not agent.get("latitude") or not agent.get("longitude"):
            continue

        # Distance livreur → partenaire
        dist_to_partner = _haversine(
            agent["latitude"], agent["longitude"],
            partner_lat, partner_lng,
        )

        # Ignorer les trop loin (> 10km)
        if dist_to_partner > 10:
            continue

        rating = float(agent.get("rating") or 5.0)

        # Score : plus c'est bas, mieux c'est
        score = (dist_to_partner * 0.6) + ((5.0 - rating) * 0.4)

        if score < best_score:
            best_score = score
            best = {**agent, "_score": score, "_dist": dist_to_partner}

    return best