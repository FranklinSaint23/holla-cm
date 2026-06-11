from fastapi import APIRouter, Header, HTTPException
from pydantic import BaseModel
from typing import Optional
import os
from services.review_service import analyze_sentiment, generate_ai_response
from supabase_client import get_supabase

router = APIRouter(prefix="/reviews", tags=["reviews"])


def _check_token(token: str):
    if token != f"Bearer {os.getenv('SECRET_TOKEN')}":
        raise HTTPException(status_code=401, detail="Non autorisé")


class ReviewRequest(BaseModel):
    order_id: str
    client_id: str
    partner_id: str
    rating: int
    comment: str


@router.post("/submit")
async def submit_review(
    body: ReviewRequest,
    authorization: str = Header(default=""),
):
    """Soumet un avis, analyse le sentiment et génère une réponse IA."""
    _check_token(authorization)
    sb = get_supabase()

    # Analyser le sentiment
    sentiment_data = await analyze_sentiment(body.comment)

    # Récupérer le nom du partenaire
    partner = sb.table("partners") \
        .select("business_name") \
        .eq("id", body.partner_id) \
        .single() \
        .execute()
    partner_name = partner.data["business_name"] if partner.data else "ce restaurant"

    # Générer réponse automatique
    ai_response = await generate_ai_response(
        review_text=body.comment,
        rating=body.rating,
        partner_name=partner_name,
        sentiment=sentiment_data["sentiment"],
    )

    # Sauvegarder en BDD
    saved = sb.table("ai_reviews").insert({
        "order_id":        body.order_id,
        "client_id":       body.client_id,
        "partner_id":      body.partner_id,
        "rating":          body.rating,
        "comment":         body.comment,
        "sentiment":       sentiment_data["sentiment"],
        "sentiment_score": sentiment_data["score"],
        "ai_response":     ai_response,
    }).execute()

    # Mettre à jour la note moyenne du partenaire
    all_reviews = sb.table("ai_reviews") \
        .select("rating") \
        .eq("partner_id", body.partner_id) \
        .execute()

    if all_reviews.data:
        avg = sum(r["rating"] for r in all_reviews.data) / len(all_reviews.data)
        sb.table("partners").update({
            "rating":       round(avg, 2),
            "reviews_count": len(all_reviews.data),
        }).eq("id", body.partner_id).execute()

    return {
        "saved":          True,
        "sentiment":      sentiment_data["sentiment"],
        "sentiment_score": sentiment_data["score"],
        "ai_response":    ai_response,
        "summary":        sentiment_data.get("summary"),
    }


@router.get("/partner/{partner_id}/analysis")
async def partner_analysis(
    partner_id: str,
    authorization: str = Header(default=""),
):
    """Analyse globale des avis d'un partenaire."""
    _check_token(authorization)
    sb = get_supabase()

    reviews = sb.table("ai_reviews") \
        .select("rating, sentiment, sentiment_score, comment") \
        .eq("partner_id", partner_id) \
        .execute()

    if not reviews.data:
        return {"total": 0}

    data = reviews.data
    total = len(data)
    avg_rating = sum(r["rating"] for r in data) / total
    avg_sentiment = sum(r.get("sentiment_score", 0) for r in data) / total

    by_sentiment = {
        "positive": len([r for r in data if r["sentiment"] == "positive"]),
        "neutral":  len([r for r in data if r["sentiment"] == "neutral"]),
        "negative": len([r for r in data if r["sentiment"] == "negative"]),
    }

    return {
        "total":           total,
        "avg_rating":      round(avg_rating, 2),
        "avg_sentiment":   round(avg_sentiment, 3),
        "by_sentiment":    by_sentiment,
        "satisfaction_pct": round(by_sentiment["positive"] / total * 100),
    }