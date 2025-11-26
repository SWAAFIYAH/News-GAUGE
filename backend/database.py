"""Database module for storing and retrieving news articles."""
import sqlite3
from datetime import datetime
from typing import List, Dict

# Database file
DB_PATH = "news_gauge.db"

def init_db():
    """Initialize database with required tables."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Create articles table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS articles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT,
            source TEXT,
            url TEXT UNIQUE,
            category TEXT,
            published_at TEXT,
            verified BOOLEAN DEFAULT 0,
            credibility_score REAL DEFAULT 0.0,
            fetched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    conn.commit()
    conn.close()
    print("✅ Database initialized")

def save_articles_to_db(articles: List[Dict], category: str) -> int:
    """Save articles to database and return count saved."""
    if not articles or isinstance(articles, dict) and "error" in articles:
        return 0
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    count = 0
    for article in articles:
        try:
            cursor.execute("""
                INSERT OR IGNORE INTO articles 
                (title, content, source, url, category, published_at)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (
                article.get("title", ""),
                article.get("description", ""),
                article.get("source", ""),
                article.get("url", ""),
                category,
                article.get("published_at", "")
            ))
            count += 1
        except sqlite3.IntegrityError:
            # URL already exists, skip
            pass
    
    conn.commit()
    conn.close()
    return count

def get_articles_by_category(category: str, limit: int = 20) -> List[Dict]:
    """Retrieve articles from database by category."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row  # Return rows as dictionaries
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT * FROM articles 
        WHERE category = ? 
        ORDER BY published_at DESC 
        LIMIT ?
    """, (category, limit))
    
    rows = cursor.fetchall()
    conn.close()
    
    return [dict(row) for row in rows]

def get_all_articles(limit: int = 100) -> List[Dict]:
    """Retrieve all articles from database."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT * FROM articles 
        ORDER BY published_at DESC 
        LIMIT ?
    """, (limit,))
    
    rows = cursor.fetchall()
    conn.close()
    
    return [dict(row) for row in rows]

def update_article_verification(article_id: int, verified: bool, credibility_score: float):
    """Update article verification status and credibility score."""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    cursor.execute("""
        UPDATE articles 
        SET verified = ?, credibility_score = ? 
        WHERE id = ?
    """, (verified, credibility_score, article_id))
    
    conn.commit()
    conn.close()

if __name__ == "__main__":
    init_db()
