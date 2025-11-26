"""
News-GAUGE: Complete News Verification Platform in Jac

Architecture:
- Fetch news from NewsAPI (via HTTP)
# - Verify credibility with LLM
"""
# --- LLM Integration (byllm) -----------------------------------------------
import from byllm.lib { Model }

# Create a global LLM model instance (adjust model_name as needed)
glob llm = Model(model_name="gpt-4o");

# Define a thin LLM function that accepts a prompt and returns the model output as string
def score_article(prompt: str) -> str by llm();

# ---------------------------------------------------------------------------
# NODES - Graph data structure
# ============================================================================

# User node: represents authenticated users
node User {
    has username: str;
    has password: str;
    has created_at: str;
}

# Article node: represents news articles
node Article {
    has title: str;
    has content: str;
    has source: str;
    has url: str;
    has category: str;
    has published_at: str;
    has fetched_at: str = "";
    has verified: bool = false;
    has credibility_score: float = 0.0;
}

# Edge: User can read articles
edge can_read {
    has timestamp: str;
}

# ============================================================================
# WALKERS - Graph operations and business logic
# ============================================================================

# Walker: Register or update user
walker update_user {
    obj __specs__ {
        static has auth: bool = False;
    }

    has username: str;
    has password: str;

    can update_user with `root entry {
        all_users = [root --> (`?User)];
        user_nodes = [u for u in all_users if u.username == self.username];
        
        if len(user_nodes) == 0 {
            # Create new user
            new_user = here ++> User(
                username=self.username, 
                password=self.password,
                created_at=str(now)
            );
            grant(new_user[0], level=ConnectPerm);
            report "✅ User registered: " + self.username;
        } else {
            # Update existing user
            user = user_nodes[0];
            user.password = self.password;
            report "✅ User updated: " + self.username;
        }
    }
}

# Walker: Login user
walker login_user {
    obj __specs__ {
        static has auth: bool = False;
    }

    has username: str;
    has password: str;

    can login with `root entry {
        all_users = [root --> (`?User)];
        user_nodes = [u for u in all_users if u.username == self.username];
        
        if len(user_nodes) == 0 {
            report "❌ Login failed: user not found";
        } else {
            user = user_nodes[0];
            if user.password == self.password {
                report "✅ Login successful for user: " + self.username;
            } else {
                report "❌ Login failed: incorrect password";
            }
        }
    }
}

# Walker: Fetch news from external API and store
walker fetch_and_store_news {
    obj __specs__ {
        static has auth: bool = False;
    }

    has category: str = "business";
    has country: str = "us";
    has limit: int = 20;

    can fetch with `root entry {
        report("⏳ Fetching " + self.category + " news...");
        
        # NOTE: In production, integrate with NewsAPI HTTP client
        # For now, store sample articles
        
        # Get or create articles container
        articles_root = [root --> (`?Article)];
        
        # Sample articles (in production, fetch from API)
        sample_articles = [
            {
                "title": "Breaking: Tech Company Announces New AI",
                "content": "A major technology company has announced groundbreaking AI research...",
                "source": "TechNews",
                "url": "https://example.com/article1",
                "published_at": "2025-11-26T12:00:00Z"
            },
            {
                "title": "Market Update: Stocks Rise",
                "content": "Stock market saw significant gains today as investors...",
                "source": "BusinessDaily",
                "url": "https://example.com/article2",
                "published_at": "2025-11-26T11:30:00Z"
            }
        ];
        
        # Store articles
        count = 0;
        for article in sample_articles {
            if article["url"] not in [a.url for a in articles_root] {
                new_article = here ++> Article(
                    title=article["title"],
                    content=article["content"],
                    source=article["source"],
                    url=article["url"],
                    category=self.category,
                    published_at=article["published_at"],
                    verified=false,
                    credibility_score=0.0,
                    fetched_at=str(now)
                );
                grant(new_article[0], level=ConnectPerm);
                count = count + 1;
            }
        }
        
        report("✅ Stored " + str(count) + " new articles for " + self.category);
    }
}

# Walker: Verify article credibility with LLM
walker verify_article {
    obj __specs__ {
        static has auth: bool = False;
    }

    has article_title: str;

    can verify with `root entry {
        # Find article by title
        all_articles = [root --> (`?Article)];
        articles = [a for a in all_articles if a.title == self.article_title];
        
        if len(articles) == 0 {
            report("❌ Article not found: " + self.article_title);
        } else {
            article = articles[0];
            
            # Build prompt for the LLM: request a single numeric score 0.0-1.0 only
            prompt = "Please evaluate the credibility of the following news article and RETURN ONLY a single numeric score between 0.0 and 1.0 (e.g. 0.82).\n" +
                     "Title: " + article.title + "\n" +
                     "Source: " + article.source + "\n" +
                     "Content: " + article.content + "\n" +
                     "\nRespond with only the decimal number and no other text.";

            # Call the LLM via the byllm Model wrapper
            raw_score = score_article(prompt);

            # Trim whitespace
            s = raw_score.strip();

            # Validate result contains only digits and at most one dot
            valid = true;
            if len(s) == 0 {
                valid = false;
            }
            dot_count = 0;
            for ch in s {
                if ch == '.' {
                    dot_count = dot_count + 1;
                } else {
                    in_digits = ch in ["0","1","2","3","4","5","6","7","8","9"];
                    if not in_digits {
                        valid = false;
                    }
                }
            }
            if dot_count > 1 {
                valid = false;
            }

            if valid {
                score = float(s);
                if score < 0.0 { score = 0.0; }
                if score > 1.0 { score = 1.0; }
            } else {
                # Fallback heuristic if LLM output couldn't be parsed
                score = min(0.95, len(article.content) / 500.0);
            }

            # Update article with verification
            article.verified = score > 0.7;
            article.credibility_score = score;

            if article.verified {
                report("✅ Article verified as credible (score: " + str(score) + ")");
            } else {
                report("⚠️ Article has low credibility (score: " + str(score) + ")");
            }
        }
    }
}

# Walker: Get articles by category for authenticated user
walker get_news_by_category {
    obj __specs__ {
        static has auth: bool = False;
    }

    has category: str;
    has limit: int = 20;

    can get_news with `root entry {
        # Find all articles in category
        all_articles = [root --> (`?Article)];
        category_articles = [a for a in all_articles if a.category == self.category];
        
        if len(category_articles) == 0 {
            report("ℹ️ No articles found in category: " + self.category);
        } else {
            # Get top articles
            top_articles = [];
            count = 0;
            for article in category_articles {
                if count < self.limit {
                    top_articles.append(article);
                    count = count + 1;
                }
            }
            
            report("📰 Found " + str(len(top_articles)) + " articles in " + self.category);
            
            # Report each article
            for article in top_articles {
                if article.verified {
                    credibility = " [Verified: " + str(article.credibility_score) + "]";
                } else {
                    credibility = " [Unverified]";
                }
                report("  - " + article.title + credibility);
            }
        }
    }
}

# Walker: List all available articles
walker list_all_articles {
    obj __specs__ {
        static has auth: bool = False;
    }

    has limit: int = 100;

    can list with `root entry {
        all_articles = [root --> (`?Article)];
        
        if len(all_articles) == 0 {
            report("ℹ️ No articles in database");
        } else {
            # Get top articles
            top_articles = [];
            count = 0;
            for article in all_articles {
                if count < self.limit {
                    top_articles.append(article);
                    count = count + 1;
                }
            }
            
            report("📊 Total articles: " + str(len(all_articles)));
            report("🔝 Showing top " + str(len(top_articles)) + " articles:");
            
            for article in top_articles {
                if article.verified {
                    status = "✅";
                } else {
                    status = "❓";
                }
                report(status + " [" + article.category + "] " + article.title);
            }
        }
    }
}

# Walker: Scheduled hourly news fetch
walker scheduled_news_fetch {
    obj __specs__ {
        static has auth: bool = False;
    }

    can fetch_hourly with `root entry {
        categories = ["business", "health", "technology", "sports", "entertainment"];
        total_new = 0;
        
        report("🔄 Starting scheduled news fetch...");
        
        for category in categories {
            # Spawn fetch_and_store_news for each category
            visit root spawn fetch_and_store_news(category=category);
            total_new = total_new + 1;
        }
        
        report("✅ Scheduled fetch completed. Processed " + str(len(categories)) + " categories");
    }
}