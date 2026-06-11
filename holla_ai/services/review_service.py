import os
import httpx
from supabase_client import get_supabase


async def analyze_sentiment(text: str) -> dict:
    """Analyse le sentiment d'un avis client avec l'IA."""
    api_key = os.getenv("ANTHROPIC_API_KEY")

    prompt = f"""Analyse le sentiment de cet avis client pour une app de livraison.
    
Avis: "{text}"

Réponds UNIQUEMENT en JSON avec ce format exact:
{{
  "sentiment": "positive" | "neutral" | "negative",
  "score": float entre -1.0 (très négatif) et 1.0 (très positif),
  "summary": "résumé en 1 phrase",
  "key_points": ["point1", "point2"]
}}"""

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
                "max_tokens": 256,
                "messages": [{
                    "role": "user",
                    "content": prompt,
                }],
            },
            timeout=15.0,
        )
        data = response.json()
        text_response = data["content"][0]["text"]

    # Parser le JSON
    import json
    import re
    match = re.search(r'\{.*\}', text_response, re.DOTALL)
    if match:
        return json.loads(match.group())
    return {"sentiment": "neutral", "score": 0.0, "summary": text, "key_points": []}


async def generate_ai_response(
    review_text: str,
    rating: int,
    partner_name: str,
    sentiment: str,
) -> str:
    """Génère une réponse automatique de l'établissement à un avis."""
    api_key = os.getenv("ANTHROPIC_API_KEY")

    prompt = f"""Tu es le responsable de {partner_name} sur HOLLA.
    
Un client a laissé cet avis (note: {rating}/5):
"{review_text}"

Sentiment détecté: {sentiment}

Génère une réponse professionnelle et chaleureuse en français.
Maximum 3 phrases. Utilise un ton adapté au sentiment.
Si négatif, sois empathique et propose de corriger.
Si positif, remercie sincèrement."""

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
                "max_tokens": 200,
                "messages": [{
                    "role": "user",
                    "content": prompt,
                }],
            },
            timeout=15.0,
        )
        data = response.json()
        return data["content"][0]["text"]