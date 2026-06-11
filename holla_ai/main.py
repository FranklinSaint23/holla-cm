from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

from routers import delivery, prediction, suggestions, chat, reviews, promotions

load_dotenv()

app = FastAPI(
    title="HOLLA AI Service",
    description="Microservice IA complet — Assistant, Avis, Recommandations",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(delivery.router)
app.include_router(prediction.router)
app.include_router(suggestions.router)
app.include_router(chat.router)
app.include_router(reviews.router)
app.include_router(promotions.router)


@app.get("/health")
async def health():
    return {
        "status":   "healthy",
        "service":  "HOLLA AI",
        "version":  "2.0.0",
        "features": [
            "delivery_assignment",
            "delivery_prediction",
            "personalized_suggestions",
            "ai_assistant",
            "sentiment_analysis",
            "auto_review_response",
            "promotions_feed",
        ],
    }