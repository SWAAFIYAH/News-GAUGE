import os
import requests


def fetch_news_from_api(api_key=None, category=None, country=None):
    """Fetch top headlines from NewsAPI.

    Parameters:
    - api_key: optional API key. If not provided, reads from `NEWSAPI_KEY` env var.
    - category: news category (e.g., 'business')
    - country: country code (e.g., 'us')

    Returns a list of article dicts on success or a dict with key "error" on failure.
    """
    api_key = api_key or os.environ.get("NEWSAPI_KEY")
    if not api_key:
        return {"error": "API key not found. Make sure NEWSAPI_KEY is set or pass api_key."}

    url = "https://newsapi.org/v2/top-headlines"
    params = {
        "apiKey": api_key,
        "category": category,
        "country": country,
    }

    try:
        response = requests.get(url, params=params, timeout=10)
    except Exception as e:
        return {"error": f"Request error when contacting NewsAPI: {e}"}

    if response.status_code != 200:
        # Try to include API error message where possible
        try:
            err = response.json()
        except Exception:
            err = response.text
        return {"error": f"Failed to fetch news: {err}"}

    try:
        data = response.json()
    except Exception as e:
        return {"error": f"Invalid JSON from NewsAPI: {e}"}

    articles = data.get("articles", [])

    formatted = []
    for item in articles:
        source = item.get("source") or {}
        # source may be a dict with 'name' or a string
        if isinstance(source, dict):
            source_name = source.get("name", "")
        else:
            source_name = str(source)

        formatted.append({
            "title": item.get("title", ""),
            "description": item.get("description", ""),
            "url": item.get("url", ""),
            "published_at": item.get("publishedAt", ""),
            "source": source_name,
        })

    return formatted
