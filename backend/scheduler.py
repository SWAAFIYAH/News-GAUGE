"""Background scheduler to fetch news every hour."""
import os
import json
import asyncio
from datetime import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from news_fetcher import fetch_news_from_api
from database import save_articles_to_db

# Categories to fetch news from
CATEGORIES = ["business", "health", "technology", "sports", "entertainment"]
COUNTRY = "us"

def fetch_and_store_news():
    """Fetch news from all categories and store in database."""
    print(f"\n[{datetime.now()}] Starting scheduled news fetch...")
    
    for category in CATEGORIES:
        try:
            print(f"  Fetching {category} news...")
            articles = fetch_news_from_api(None, category, COUNTRY)
            
            if isinstance(articles, dict) and "error" in articles:
                print(f"    ❌ Error: {articles['error']}")
                continue
            
            # Save to database
            count = save_articles_to_db(articles, category)
            print(f"    ✅ Saved {count} articles for {category}")
            
        except Exception as e:
            print(f"    ❌ Exception: {e}")
    
    print(f"[{datetime.now()}] News fetch completed.\n")

def start_scheduler():
    """Start the background scheduler."""
    scheduler = BackgroundScheduler()
    
    # Schedule news fetching every hour
    scheduler.add_job(
        fetch_and_store_news,
        'interval',
        hours=1,
        id='fetch_news_hourly',
        name='Fetch news every hour',
        replace_existing=True
    )
    
    scheduler.start()
    print("✅ Scheduler started. News will be fetched every hour.")
    return scheduler

if __name__ == "__main__":
    scheduler = start_scheduler()
    try:
        asyncio.get_event_loop().run_forever()
    except KeyboardInterrupt:
        scheduler.shutdown()
        print("Scheduler stopped.")
