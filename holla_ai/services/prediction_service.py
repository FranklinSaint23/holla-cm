import math
from datetime import datetime
from supabase_client import get_supabase


def predict_delivery_time(
    partner_lat: float,
    partner_lng: float,
    delivery_lat: float,
    delivery_lng: float,
) -> int:
    """
    Prédit le délai de livraison en minutes.
    Facteurs : distance, heure de pointe, charge partenaire.
    """
    # Distance en km
    R = 6371.0
    dlat = math.radians(delivery_lat - partner_lat)
    dlon = math.radians(delivery_lng - partner_lng)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(partner_lat)) *
         math.cos(math.radians(delivery_lat)) *
         math.sin(dlon / 2) ** 2)
    distance_km = R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # Vitesse moyenne moto à Yaoundé (en km/h)
    hour = datetime.now().hour
    is_rush = (7 <= hour <= 9) or (17 <= hour <= 19)
    avg_speed = 15 if is_rush else 25

    # Temps de transit
    transit_min = (distance_km / avg_speed) * 60

    # Temps de préparation moyen
    prep_min = 15

    # Marge (+20%)
    total = (transit_min + prep_min) * 1.2

    return max(10, int(total))


def get_demand_prediction(partner_id: str) -> dict:
    """
    Prédit la demande pour les 3 prochaines heures.
    Basé sur l'historique des commandes.
    """
    sb = get_supabase()
    now = datetime.now()

    # Commandes des 30 derniers jours pour ce partenaire
    orders = sb.table("orders") \
        .select("created_at") \
        .eq("partner_id", partner_id) \
        .eq("status", "delivered") \
        .execute()

    if not orders.data:
        return {"predictions": [5, 4, 3], "peak_hour": None}

    # Comptage par heure
    hourly = [0] * 24
    for order in orders.data:
        try:
            dt = datetime.fromisoformat(order["created_at"].replace("Z", "+00:00"))
            hourly[dt.hour] += 1
        except Exception:
            continue

    # Normaliser
    total = sum(hourly) or 1
    hourly_pct = [round(h / total * 100) for h in hourly]

    # Prédictions pour les 3 prochaines heures
    predictions = [
        hourly_pct[(now.hour + i) % 24]
        for i in range(1, 4)
    ]

    peak_hour = hourly.index(max(hourly))

    return {
        "predictions": predictions,
        "peak_hour": peak_hour,
        "hourly_distribution": hourly_pct,
    }