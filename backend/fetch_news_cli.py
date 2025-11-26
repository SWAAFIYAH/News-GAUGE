#!/usr/bin/env python3
"""Standalone script to fetch news from NewsAPI."""
import os
import sys
import json
from news_fetcher import fetch_news_from_api

if __name__ == "__main__":
    api_key = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("NEWSAPI_KEY")
    category = sys.argv[2] if len(sys.argv) > 2 else "business"
    country = sys.argv[3] if len(sys.argv) > 3 else "us"
    
    result = fetch_news_from_api(api_key, category, country)
    print(json.dumps(result, indent=2))
