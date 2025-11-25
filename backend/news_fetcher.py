import os
import requests

def fetch_news_from_api(api_key,category, country):
    api_key = os.environ.get("NEWSAPI_KEY")
    if not api_key:
        return {"error": "API key not found. Make sure NEWSAPI_KEY is set."}

    url = "https://newsapi.org/v2/top-headlines"
    params = {
        "apiKey": api_key,
        "category": category,
        "country": country,
        
    }

    response = requests.get(url, params=params)
    if response.status_code != 200:
        return {"error": f"Failed to fetch news: {response.text}"}

    data = response.json()
    articles = data.get("articles", [])

    formatted = []
    for item in articles:
        formatted.append({
            "title": item.get("title", ""),
            "description": item.get("description", ""),
            "url": item.get("url", ""),
            "published_at": item.get("publishedAt", ""),
            "source": item.get("source", {}).get("name", "")
        })
    return formatted
