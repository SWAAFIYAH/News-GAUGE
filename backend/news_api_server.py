"""FastAPI server for News-GAUGE backend."""
import os
import sys
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from news_fetcher import fetch_news_from_api
from database import init_db, get_articles_by_category, get_all_articles, save_articles_to_db
from verify_news import verify_articles_batch
from scheduler import start_scheduler

app = FastAPI(title="News-GAUGE API", version="1.0.0")

# CORS configuration for frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize database on startup
@app.on_event("startup")
async def startup_event():
    """Initialize database and start scheduler on server startup."""
    init_db()
    start_scheduler()
    print("✅ News-GAUGE API Server started")

# ============================================================================
# ENDPOINTS
# ============================================================================

@app.get("/")
def root():
    """Root endpoint."""
    return {
        "message": "News-GAUGE API",
        "version": "1.0.0",
        "endpoints": {
            "fetch_news": "GET /fetch_news?category=business&country=us",
            "get_articles_by_category": "GET /articles?category=business&limit=20",
            "get_all_articles": "GET /articles/all?limit=100"
        }
    }

@app.get("/fetch_news")
def fetch_news_endpoint(
    api_key: str | None = None, 
    category: str = "business", 
    country: str = "us"
):
    """Fetch news from NewsAPI (real-time)."""
    final_api_key = api_key or os.environ.get("NEWSAPI_KEY")
    
    result = fetch_news_from_api(final_api_key, category, country)
    
    if isinstance(result, dict) and "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])
    
    # Verify articles with LLM
    verified_articles = verify_articles_batch(result)
    
    # Save to database
    count = save_articles_to_db(verified_articles, category)
    
    return {
        "status": "success",
        "count": len(verified_articles),
        "saved_to_db": count,
        "articles": verified_articles,
        "category": category,
        "country": country
    }

@app.get("/articles")
def get_articles_by_category_endpoint(
    category: str = Query(..., description="News category"),
    limit: int = Query(20, description="Number of articles to return")
):
    """Retrieve articles from database by category."""
    articles = get_articles_by_category(category, limit)
    
    if not articles:
        raise HTTPException(status_code=404, detail=f"No articles found for category: {category}")
    
    return {
        "status": "success",
        "category": category,
        "count": len(articles),
        "articles": articles
    }

@app.get("/articles/all")
def get_all_articles_endpoint(limit: int = Query(100, description="Number of articles to return")):
    """Retrieve all articles from database."""
    articles = get_all_articles(limit)
    
    if not articles:
        raise HTTPException(status_code=404, detail="No articles found in database")
    
    return {
        "status": "success",
        "count": len(articles),
        "articles": articles
    }

@app.get("/healthz")
def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "message": "News-GAUGE API is running"}

# CLI support for running directly
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)


