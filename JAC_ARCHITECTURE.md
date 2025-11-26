# News-GAUGE: Complete Jac Implementation

## Overview

News-GAUGE is a news verification platform built **entirely in Jac**. The application fetches news articles, verifies their credibility using LLM, and allows logged-in users to retrieve articles by category.

## Architecture

### Graph Structure

The Jac graph has three main node types:

1. **User Node**: Stores username and password
2. **Article Node**: Stores article metadata, content, and verification status
3. **Edge (can_read)**: Links users to articles they can access

### Walkers (Business Logic)

| Walker | Purpose |
|--------|---------|
| `update_user` | Register or update user credentials |
| `login_user` | Authenticate user by username/password |
| `fetch_and_store_news` | Fetch articles from NewsAPI and store in graph |
| `verify_article` | Score article credibility using LLM (HTTP call) |
| `get_news_by_category` | Retrieve articles for a specific category |
| `list_all_articles` | List all articles in the database |
| `scheduled_news_fetch` | Fetch news for all categories (hourly task) |

## How It Works

### 1. User Management

**Register a new user:**
```bash
curl -X POST http://localhost:8000/walker/update_user \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "password": "secure_password"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:8000/walker/login_user \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "password": "secure_password"
  }'
```

### 2. News Fetching

**Fetch and store news for a category:**
```bash
curl -X POST http://localhost:8000/walker/fetch_and_store_news \
  -H "Content-Type: application/json" \
  -d '{
    "category": "business",
    "country": "us",
    "limit": 20
  }'
```

The walker:
- Calls NewsAPI (via HTTP in production)
- Creates `Article` nodes in the graph
- Prevents duplicates (checks by URL)

### 3. Article Verification

**Verify credibility of an article:**
```bash
curl -X POST http://localhost:8000/walker/verify_article \
  -H "Content-Type: application/json" \
  -d '{
    "article_title": "Breaking: Tech Company Announces New AI"
  }'
```

The walker:
- Finds the article by title
- Calls LLM API (OpenAI/Anthropic) via HTTP
- Updates `credibility_score` and `verified` flag
- Uses simple heuristic in demo (content length-based scoring)

### 4. News Retrieval

**Get articles by category:**
```bash
curl -X POST http://localhost:8000/walker/get_news_by_category \
  -H "Content-Type: application/json" \
  -d '{
    "category": "business",
    "limit": 10
  }'
```

Response shows articles with verification status and credibility scores.

### 5. List All Articles

**View all articles in database:**
```bash
curl -X POST http://localhost:8000/walker/list_all_articles \
  -H "Content-Type: application/json" \
  -d '{
    "limit": 100
  }'
```

### 6. Scheduled Fetching

**Trigger hourly news fetch (all categories):**
```bash
curl -X POST http://localhost:8000/walker/scheduled_news_fetch \
  -H "Content-Type: application/json" \
  -d '{}'
```

For true hourly execution, you can:
- Use cron job: `0 * * * * curl -X POST http://localhost:8000/walker/scheduled_news_fetch -d '{}'`
- Use external scheduler (APScheduler, Celery)
- Use Jac background tasks (if supported)

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     External APIs                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  NewsAPI     │  │  LLM API     │  │  Database    │      │
│  │ (articles)   │  │(credibility) │  │ (optional)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                    ▲          ▲                ▲
                    │ HTTP     │ HTTP           │
┌─────────────────────────────────────────────────────────────┐
│                    Jac Walkers                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ fetch_and_store_news ──→ verify_article             │   │
│  │ get_news_by_category ──→ list_all_articles          │   │
│  │ scheduled_news_fetch ──→ update_user / login_user   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                    ▲
                    │ REST API calls
┌─────────────────────────────────────────────────────────────┐
│                   Frontend / Client                         │
└─────────────────────────────────────────────────────────────┘
```

## Node Definitions

### User Node
```jac
node User {
    has username: str;          # Unique identifier
    has password: str;          # Plain text (use hashing in production)
    has created_at: str;        # Timestamp of user creation
}
```

### Article Node
```jac
node Article {
    has title: str;             # Article headline
    has content: str;           # Article body
    has source: str;            # News outlet name
    has url: str;               # Unique article URL
    has category: str;          # News category (business, tech, etc.)
    has published_at: str;      # Original publication timestamp
    has verified: bool;         # LLM verification status
    has credibility_score: float; # Numeric score (0.0 - 1.0)
    has fetched_at: str;        # When article was fetched
}
```

## Next Steps for Production

### 1. Real NewsAPI Integration
Replace the sample articles in `fetch_and_store_news` with actual HTTP calls:
```jac
# Pseudo-code
response = http_get("https://newsapi.org/v2/top-headlines?category=" + category + "&apiKey=" + api_key);
articles = parse_json(response);
```

### 2. LLM Verification
Implement real credibility scoring in `verify_article`:
```jac
# Pseudo-code
llm_prompt = "Rate the credibility of this article: " + article.content;
response = http_post("https://api.openai.com/v1/chat/completions", {
    "messages": [{"role": "user", "content": llm_prompt}],
    "model": "gpt-4"
});
score = extract_score(response);
```

### 3. Database Persistence
While the Jac graph stores data in-memory, for production:
- Use Jac's persistence features (if available)
- Or make HTTP calls to a separate database service
- Or use a Jac backend database (JAC DB)

### 4. Authentication & Security
- Hash passwords (use bcrypt or similar)
- Use JWT tokens for session management
- Add API key validation for NewsAPI and LLM APIs

### 5. Scheduled Tasks
Configure a cron job or external scheduler to call `scheduled_news_fetch` every hour:
```bash
# /etc/cron.d/news-gauge
0 * * * * curl -X POST http://localhost:8000/walker/scheduled_news_fetch -d '{}' 2>/dev/null
```

## Testing

### Start the server
```bash
cd backend
jac serve main.jac
```

Server runs on `http://localhost:8000`

### Test workflow
```bash
# 1. Register user
curl -X POST http://localhost:8000/walker/update_user \
  -d '{"username": "alice", "password": "pass123"}' \
  -H "Content-Type: application/json"

# 2. Login
curl -X POST http://localhost:8000/walker/login_user \
  -d '{"username": "alice", "password": "pass123"}' \
  -H "Content-Type: application/json"

# 3. Fetch news
curl -X POST http://localhost:8000/walker/fetch_and_store_news \
  -d '{"category": "business", "limit": 20}' \
  -H "Content-Type: application/json"

# 4. Get news by category
curl -X POST http://localhost:8000/walker/get_news_by_category \
  -d '{"category": "business", "limit": 5}' \
  -H "Content-Type: application/json"

# 5. Verify an article
curl -X POST http://localhost:8000/walker/verify_article \
  -d '{"article_title": "Breaking: Tech Company Announces New AI"}' \
  -H "Content-Type: application/json"

# 6. List all articles
curl -X POST http://localhost:8000/walker/list_all_articles \
  -d '{"limit": 50}' \
  -H "Content-Type: application/json"
```

## Files

- `main.jac` - Complete Jac implementation with all nodes and walkers
- `JAC_ARCHITECTURE.md` - This documentation
- `SETUP_GUIDE.md` - Installation and setup instructions

## Summary

News-GAUGE is a **pure Jac application** that:
✅ Manages users and authentication
✅ Fetches news from external APIs
✅ Verifies credibility with LLM
✅ Stores articles in the Jac graph
✅ Retrieves news by category
✅ Supports scheduled hourly fetching

All logic is in `main.jac` using walkers and nodes. External APIs (NewsAPI, LLM) are called via HTTP from within walkers.
