from datetime import datetime
from supabase_client import get_supabase


def get_promotions_nearby(
    lat: float,
    lng: float,
    radius_km: float = 10,
) -> list:
    """Récupère les offres du jour actives."""
    import math

    sb = get_supabase()
    now = datetime.utcnow().isoformat()

    promos = sb.table("promotions") \
        .select("*, partners(business_name, latitude, longitude, image_url)") \
        .eq("is_active", True) \
        .lte("starts_at", now) \
        .gte("ends_at", now) \
        .execute()

    if not promos.data:
        return []

    def dist(lat1, lon1, lat2, lon2):
        R = 6371
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * \
            math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
        return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    result = []
    for p in promos.data:
        partner = p.get("partners", {})
        if partner.get("latitude") and partner.get("longitude"):
            distance = dist(lat, lng, partner["latitude"], partner["longitude"])
            if distance <= radius_km:
                result.append({
                    **p,
                    "partner_name": partner["business_name"],
                    "distance_km":  round(distance, 1),
                })

    return sorted(result, key=lambda x: x["distance_km"])


def get_personalized_feed(client_id: str, lat: float, lng: float) -> dict:
    """
    Génère un feed personnalisé complet :
    - Offres du jour proches
    - Partenaires favoris
    - Suggestions basées sur l'heure
    - Nouveaux partenaires à découvrir
    """
    sb = get_supabase()
    hour = datetime.now().hour

    # Offres du jour
    promos = get_promotions_nearby(lat, lng)

    # Partenaires les plus commandés par ce client
    orders = sb.table("orders") \
        .select("partner_id") \
        .eq("client_id", client_id) \
        .eq("status", "delivered") \
        .limit(50) \
        .execute()

    fav_ids = {}
    for o in (orders.data or []):
        pid = o["partner_id"]
        fav_ids[pid] = fav_ids.get(pid, 0) + 1

    top_ids = sorted(fav_ids, key=fav_ids.get, reverse=True)[:3]

    favorites = []
    for pid in top_ids:
        p = sb.table("partners") \
            .select("*") \
            .eq("id", pid) \
            .single() \
            .execute()
        if p.data:
            favorites.append(p.data)

    # Suggestion selon l'heure
    if 6 <= hour < 11:
        time_suggestion = "breakfast"
        time_label = "☀️ Petit-déjeuner"
    elif 11 <= hour < 15:
        time_suggestion = "lunch"
        time_label = "🍽️ Déjeuner"
    elif 18 <= hour < 22:
        time_suggestion = "dinner"
        time_label = "🌙 Dîner"
    else:
        time_suggestion = "snack"
        time_label = "🍿 Snack"

    return {
        "promotions":       promos[:5],
        "favorites":        favorites,
        "time_label":       time_label,
        "time_suggestion":  time_suggestion,
    }