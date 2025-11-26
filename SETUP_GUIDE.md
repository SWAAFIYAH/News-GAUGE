# News-GAUGE Setup Guide

## Complete System Architecture

```
FRONTEND (React/Vue)
    ↓
    ├→ Jac Server (port 8000) - User Auth & Graph
    │   - Register users
    │   - Login users
    │   - Graph operations
    │
    └→ FastAPI Server (port 8001) - News & Verification
        - Fetch news every hour (scheduler)
        - Verify with LLM
        - Store in database
        - Serve articles by category
```

## Quick Start

### 1. Initialize Database
```bash
cd backend
export NEWSAPI_KEY="your_newsapi_key"
./venv/bin/python3 database.py
```

### 2. Start the News API Server (with scheduler)
```bash
./venv/bin/uvicorn news_api_server:app --port 8001
# This automatically:
# - Starts scheduler
# - Fetches news every hour
# - Verifies and stores in DB
```

### 3. Start Jac Server (in another terminal)
```bash
jac serve main.jac
# Runs on port 8000
```

### 4. From Your Frontend, Call These Endpoints

**Get news by category:**
```javascript
const response = await fetch('http://localhost:8001/articles?category=business&limit=20');
const data = await response.json();
// Returns: { status: "success", articles: [...] }
```

**Register user:**
```javascript
const response = await fetch('http://localhost:8000/walker/update_user', {
  method: 'POST',
  body: JSON.stringify({
    username: "john_doe",
    password: "secret123"
  })
});
```

**Login user:**
```javascript
const response = await fetch('http://localhost:8000/walker/login_user', {
  method: 'POST',
  body: JSON.stringify({
    username: "john_doe",
    password: "secret123"
  })
});
```

## What Happens Every Hour

1. Scheduler triggers `fetch_and_store_news()`
2. For each category (business, health, tech, sports, entertainment):
   - Fetch latest articles from NewsAPI
   - Verify credibility with LLM
   - Store in database with credibility score
3. Log completion

## Available API Endpoints

### FastAPI (port 8001)
- `GET /` - API info
- `GET /fetch_news?category=business` - Fetch + verify + store
- `GET /articles?category=business&limit=20` - Get from DB
- `GET /articles/all?limit=100` - Get all articles
- `GET /healthz` - Health check

### Jac (port 8000)
- `POST /walker/update_user` - Register/update user
- `POST /walker/login_user` - Login user
- `POST /walker/fetch_news` - Trigger news fetch (from Jac)

## File Descriptions

| File | Purpose |
|------|---------|
| `main.jac` | Graph nodes (User, article) and walkers (auth) |
| `news_fetcher.py` | Fetches from NewsAPI |
| `verify_news.py` | LLM credibility verification |
| `database.py` | SQLite storage |
| `scheduler.py` | Hourly background task |
| `news_api_server.py` | FastAPI endpoints |
| `fetch_news_cli.py` | CLI tool |

## Understanding the Data Flow

```
1. Raw News
   (NewsAPI)
       ↓
2. Fetched Articles
   (news_fetcher.py)
       ↓
3. Verified Articles
   (verify_news.py adds credibility_score)
       ↓
4. Stored Articles
   (database.py saves to SQLite)
       ↓
5. User Retrieval
   (Frontend requests by category)
```

## Testing

### Test News Fetching
```bash
./venv/bin/python3 fetch_news_cli.py "" business us
```

### Test Database
```bash
./venv/bin/python3 database.py
sqlite3 news_gauge.db "SELECT COUNT(*) FROM articles;"
```

### Test API
```bash
curl "http://localhost:8001/articles?category=business"
```

### Test Scheduler (check logs)
```bash
# Logs appear in the FastAPI server console
# Shows when news is fetched each hour
```

## Troubleshooting

**Q: "API key not found"**
A: Set the environment variable:
```bash
export NEWSAPI_KEY="your_actual_key"
```

**Q: Database file not created**
A: Run:
```bash
./venv/bin/python3 database.py
```

**Q: Port already in use**
A: Kill existing processes:
```bash
lsof -t -i:8000 | xargs kill -9
lsof -t -i:8001 | xargs kill -9
```

**Q: No articles in database**
A: 
- Scheduler runs every hour automatically
- Or manually trigger: `curl "http://localhost:8001/fetch_news?category=business"`
- Wait a moment, then query: `curl "http://localhost:8001/articles?category=business"`
