import os
import httpx
from typing import Optional
from supabase_client import get_supabase


SYSTEM_PROMPT = """
Tu es HOLLA Assistant, l'assistant intelligent de l'application HOLLA — 
Intelligent Urban Delivery à Yaoundé, Cameroun.

Tu parles français et anglais selon la langue de l'utilisateur.
Tu es chaleureux, professionnel et concis.

Tu peux aider avec :
- Questions sur les commandes (statut, délais, annulation)
- Recommandations de restaurants et boutiques
- Informations sur les services à domicile
- Promotions et offres du jour
- Problèmes de paiement Mobile Money
- Informations générales sur HOLLA

Ce que tu NE peux PAS faire :
- Modifier une commande directement (redirige vers le support)
- Promettre des délais précis
- Donner des informations personnelles d'autres clients

Réponds toujours en moins de 3 phrases sauf si l'utilisateur demande des détails.
Utilise des emojis avec modération pour être plus chaleureux.
"""


async def chat_with_ai(
    message: str,
    conversation_history: list,
    context: dict,
) -> str:
    """
    Appel à Claude claude-haiku-4-5-20251001 via l'API Anthropic.
    Context contient les infos pertinentes : commandes actives, offres du jour, etc.
    """
    api_key = os.getenv("ANTHROPIC_API_KEY")

    # Construire le contexte dynamique
    context_text = _build_context(context)

    system = f"{SYSTEM_PROMPT}\n\n{context_text}"

    # Construire l'historique de messages
    messages = []
    for msg in conversation_history[-10:]:  # 10 derniers messages max
        messages.append({
            "role": msg["role"],
            "content": msg["content"],
        })
    messages.append({"role": "user", "content": message})

    async with httpx.AsyncClient() as client:
        response = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": api_key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={
                "model": "claude-haiku-4-5-20251001",
                "max_tokens": 512,
                "system": system,
                "messages": messages,
            },
            timeout=30.0,
        )
        data = response.json()
        return data["content"][0]["text"]


def _build_context(context: dict) -> str:
    """Construit le contexte dynamique pour l'IA."""
    parts = []

    # Commandes actives du client
    if context.get("active_orders"):
        orders_text = "\n".join([
            f"- Commande #{o['id'][:8]} chez {o['partner_name']} "
            f"— Statut: {o['status']}"
            for o in context["active_orders"]
        ])
        parts.append(f"COMMANDES ACTIVES DU CLIENT:\n{orders_text}")

    # Offres du jour disponibles
    if context.get("promotions"):
        promos_text = "\n".join([
            f"- {p['title']} chez {p['partner_name']}: "
            f"{p['promo_price']} FCFA (au lieu de {p['original_price']} FCFA) "
            f"— valable jusqu'à {p['ends_at']}"
            for p in context["promotions"]
        ])
        parts.append(f"OFFRES DU JOUR:\n{promos_text}")

    # Partenaires recommandés
    if context.get("top_partners"):
        partners_text = "\n".join([
            f"- {p['business_name']} ({p['business_type']}) "
            f"— Note: {p['rating']}/5 — {p.get('delivery_time', 30)} min"
            for p in context["top_partners"]
        ])
        parts.append(f"PARTENAIRES DISPONIBLES:\n{partners_text}")

    if not parts:
        return "Aucune donnée contextuelle disponible."

    return "DONNÉES EN TEMPS RÉEL:\n" + "\n\n".join(parts)