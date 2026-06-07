import os
from typing import List, Optional
import requests
from fastapi import HTTPException
from app.config.settings import get_settings


def _build_query(category: Optional[str] = None) -> str:
    """Return the query string for NewsAPI.
    If ``category`` is provided and is one of the supported keywords, it is used directly.
    Otherwise the default composite query is returned.
    """
    supported = {
        "wedding",
        "birthday",
        "corporate",
        "photography",
        "catering",
        "decoration",
        "events",
    }
    if category and category.lower() in supported:
        return category.lower()
    # default event‑related search string
    return "event planning OR wedding OR catering OR photography OR decoration"


def get_event_news(category: Optional[str] = None) -> List[dict]:
    """Fetch up to 20 event‑related articles from NewsAPI.

    The function:
    * Reads the API key from the ``NEWS_API_KEY`` environment variable via settings.
    * Constructs the query string (default or based on ``category``).
    * Calls ``https://newsapi.org/v2/everything`` with required params.
    * Maps each article to the ``BlogResponse`` schema fields.
    * Skips articles missing a ``title`` or ``url``.
    * Raises ``HTTPException`` with 503 when the external service is unavailable.
    """
    settings = get_settings()
    api_key = getattr(settings, "news_api_key", None) or os.getenv("NEWS_API_KEY")
    if not api_key:
        raise HTTPException(status_code=503, detail="News service unavailable")

    query = _build_query(category)
    params = {
        "q": query,
        "language": "en",
        "sortBy": "publishedAt",
        "pageSize": 20,
        "apiKey": api_key,
    }
    try:
        response = requests.get("https://newsapi.org/v2/everything", params=params, timeout=10)
        if response.status_code != 200:
            raise HTTPException(status_code=503, detail="News service unavailable")
        data = response.json()
        articles = data.get("articles", [])
        result: List[dict] = []
        for article in articles:
            title = article.get("title")
            url = article.get("url")
            if not title or not url:
                continue
            result.append({
                "title": title,
                "description": article.get("description"),
                "image_url": article.get("urlToImage"),
                "source": article.get("source", {}).get("name"),
                "published_at": article.get("publishedAt"),
                "url": url,
            })
        return result
    except requests.RequestException:
        raise HTTPException(status_code=503, detail="News service unavailable")
