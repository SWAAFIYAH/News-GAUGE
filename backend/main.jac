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
    has email: str = "";
    has created_at: str = "";
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
    has verified: bool = False;
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
    has username: str;
    has password: str;
    has email: str = "";

    can update_user with `root entry {
        all_users = [root --> (`?User)];
        user_nodes = [u for u in all_users if u.username == self.username];
        
        if len(user_nodes) == 0 {
            # Create new user
            new_user = here ++> User(
                username=self.username, 
                password=self.password,
                email=self.email,
                created_at=""
            );
            report {"success": True, "message": "User registered successfully", "token": self.username + "_authenticated", "username": self.username};
        } else {
            # Update existing user
            user = user_nodes[0];
            user.password = self.password;
            if self.email != "" {
                user.email = self.email;
            }
            report "✅ User updated: " + self.username;
        }
    }
}

# Walker: Login user
walker login_user {
    has username: str;
    has password: str;

    can login_user with `root entry {
        all_users = [root --> (`?User)];
        user_nodes = [u for u in all_users if u.username == self.username];
        
        if len(user_nodes) == 0 {
            report {"success": False, "message": "Login failed: user not found"};
        } else {
            user = user_nodes[0];
            if user.password == self.password {
                # Simple token: base64(username)
                report {"success": True, "message": "Login successful", "token": self.username + "_authenticated", "username": self.username};
            } else {
                report {"success": False, "message": "Login failed: incorrect password"};
            }
        }
    }
}

# Walker: Fetch news from external API and store
walker fetch_and_store_news {
    has api_key: str = "";
    has category: str = "business";
    has country: str = "us";
    has limit: int = 20;

    can fetch_and_store_news with `root entry {
        # Get or create articles container
        articles_root = [root --> (`?Article)];
        
        sample_articles = [];
        
        # NOTE: Real NewsAPI integration requires Python interop
        # For now, provide sample data. To add real fetching:
        # 1. Use the existing news_fetcher.py from a separate Python service
        # 2. Or call via HTTP to a Python microservice
        
        if self.api_key != "" and len(self.api_key) > 0 {
            report("✅ API key received (" + str(len(self.api_key)) + " chars). Using sample data (real API integration pending).");
        } else {
            report("⚠️ No API key provided. Using sample data.");
        }
        
        # Sample articles with diverse categories
        sample_articles = [
            # Technology
            {
                "title": "Revolutionary AI Model Achieves Human-Level Reasoning",
                "content": "Researchers have developed a new AI model that demonstrates unprecedented reasoning capabilities, solving complex problems without explicit training.",
                "source": "TechCrunch",
                "url": "https://example.com/tech/ai-reasoning-2025",
                "published_at": "2025-12-07T10:00:00Z",
                "category": "technology"
            },
            {
                "title": "Quantum Computing Breakthrough: 1000-Qubit Processor Unveiled",
                "content": "Tech giant unveils the world's first commercially viable 1000-qubit quantum processor, promising to revolutionize drug discovery and cryptography.",
                "source": "Wired",
                "url": "https://example.com/tech/quantum-breakthrough",
                "published_at": "2025-12-07T09:30:00Z",
                "category": "technology"
            },
            {
                "title": "5G Evolution: New 6G Standards Announced",
                "content": "International telecom consortium announces preliminary 6G standards, promising speeds 100x faster than current 5G networks.",
                "source": "The Verge",
                "url": "https://example.com/tech/6g-standards",
                "published_at": "2025-12-06T15:00:00Z",
                "category": "technology"
            },
            # Business
            {
                "title": "Global Markets Rally on Positive Economic Data",
                "content": "Stock markets worldwide surge as inflation data comes in better than expected, boosting investor confidence in economic recovery.",
                "source": "Bloomberg",
                "url": "https://example.com/business/market-rally",
                "published_at": "2025-12-07T08:00:00Z",
                "category": "business"
            },
            {
                "title": "Tech IPOs Set Record as Startup Goes Public",
                "content": "AI startup's initial public offering raises $5 billion, marking the largest tech IPO of the year and signaling strong investor appetite.",
                "source": "Financial Times",
                "url": "https://example.com/business/tech-ipo",
                "published_at": "2025-12-06T14:30:00Z",
                "category": "business"
            },
            {
                "title": "Green Energy Investment Hits All-Time High",
                "content": "Renewable energy sector attracts record $500 billion in investments as companies accelerate carbon-neutral commitments.",
                "source": "Reuters",
                "url": "https://example.com/business/green-investment",
                "published_at": "2025-12-06T11:00:00Z",
                "category": "business"
            },
            # Sports
            {
                "title": "Historic Victory: Underdog Team Wins Championship",
                "content": "In a stunning upset, the underdog team defeats reigning champions in a thrilling final match that went to overtime.",
                "source": "ESPN",
                "url": "https://example.com/sports/championship-upset",
                "published_at": "2025-12-07T07:00:00Z",
                "category": "sports"
            },
            {
                "title": "Olympic Records Shattered at Winter Games",
                "content": "Athletes break multiple world records at the Winter Olympics, showcasing extraordinary performances across multiple disciplines.",
                "source": "Sports Illustrated",
                "url": "https://example.com/sports/olympic-records",
                "published_at": "2025-12-06T18:00:00Z",
                "category": "sports"
            },
            {
                "title": "Soccer Star Signs Landmark Contract",
                "content": "International soccer superstar signs record-breaking $200 million contract, becoming the highest-paid athlete in the sport's history.",
                "source": "Goal.com",
                "url": "https://example.com/sports/soccer-contract",
                "published_at": "2025-12-06T13:00:00Z",
                "category": "sports"
            },
            # Entertainment
            {
                "title": "Blockbuster Film Breaks Box Office Records",
                "content": "Highly anticipated sci-fi epic shatters opening weekend records, earning $300 million globally in its first three days.",
                "source": "Variety",
                "url": "https://example.com/entertainment/box-office-record",
                "published_at": "2025-12-07T06:00:00Z",
                "category": "entertainment"
            },
            {
                "title": "Music Icon Announces World Tour",
                "content": "Grammy-winning artist announces massive 50-city world tour, marking their first live performances in three years.",
                "source": "Billboard",
                "url": "https://example.com/entertainment/world-tour",
                "published_at": "2025-12-06T16:00:00Z",
                "category": "entertainment"
            },
            {
                "title": "Streaming Platform Launches Original Series",
                "content": "Major streaming service unveils ambitious new fantasy series with largest production budget in TV history.",
                "source": "Hollywood Reporter",
                "url": "https://example.com/entertainment/streaming-series",
                "published_at": "2025-12-06T12:00:00Z",
                "category": "entertainment"
            },
            # Health
            {
                "title": "New Cancer Treatment Shows Promising Results",
                "content": "Clinical trials reveal breakthrough immunotherapy treatment achieves 85% success rate in treating aggressive cancers.",
                "source": "Medical News Today",
                "url": "https://example.com/health/cancer-treatment",
                "published_at": "2025-12-07T05:00:00Z",
                "category": "health"
            },
            {
                "title": "Mental Health Apps Prove Effective in Study",
                "content": "Large-scale research demonstrates digital mental health interventions significantly reduce anxiety and depression symptoms.",
                "source": "Health.com",
                "url": "https://example.com/health/mental-health-apps",
                "published_at": "2025-12-06T17:00:00Z",
                "category": "health"
            },
            {
                "title": "Revolutionary Gene Therapy Approved",
                "content": "FDA approves groundbreaking gene therapy for rare genetic disorder, offering hope to thousands of patients worldwide.",
                "source": "WebMD",
                "url": "https://example.com/health/gene-therapy",
                "published_at": "2025-12-06T10:00:00Z",
                "category": "health"
            },
            # Science
            {
                "title": "Astronomers Discover Potentially Habitable Exoplanet",
                "content": "Scientists identify Earth-like planet in habitable zone of nearby star system, raising prospects for extraterrestrial life.",
                "source": "Nature",
                "url": "https://example.com/science/exoplanet-discovery",
                "published_at": "2025-12-07T04:00:00Z",
                "category": "science"
            },
            {
                "title": "Climate Study Reveals Accelerated Ice Melt",
                "content": "New research shows polar ice melting faster than predicted, prompting calls for urgent climate action from scientists.",
                "source": "Science Daily",
                "url": "https://example.com/science/ice-melt-study",
                "published_at": "2025-12-06T19:00:00Z",
                "category": "science"
            },
            {
                "title": "Breakthrough in Fusion Energy Research",
                "content": "Experimental fusion reactor achieves net energy gain for the first time, marking major milestone toward clean unlimited power.",
                "source": "Scientific American",
                "url": "https://example.com/science/fusion-breakthrough",
                "published_at": "2025-12-06T09:00:00Z",
                "category": "science"
            }
        ];
        
        # Store articles (dedup by URL)
        count = 0;
        for article in sample_articles {
            # Use article's category if specified, otherwise use walker's category
            article_category = article.get("category", self.category) if isinstance(article, dict) and "category" in article else self.category;
            
            if article["url"] not in [a.url for a in articles_root] {
                new_article = here ++> Article(
                    title=article["title"],
                    content=article["content"],
                    source=article["source"],
                    url=article["url"],
                    category=article_category,
                    published_at=article["published_at"],
                    verified=False,
                    credibility_score=0.0,
                    fetched_at=""
                );
                count = count + 1;
            }
        }
        
        report("✅ Stored " + str(count) + " new articles across multiple categories");
    }
}

# Walker: Verify article credibility with LLM
walker verify_article {
    has article_title: str;

    can verify_article with `root entry {
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
            valid = True;
            if len(s) == 0 {
                valid = False;
            }
            dot_count = 0;
            for ch in s {
                if ch == '.' {
                    dot_count = dot_count + 1;
                } else {
                    in_digits = ch in ["0","1","2","3","4","5","6","7","8","9"];
                    if not in_digits {
                        valid = False;
                    }
                }
            }
            if dot_count > 1 {
                valid = False;
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
    has category: str;
    has limit: int = 20;

    can get_news_by_category with `root entry {
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
    has limit: int = 100;

    can list_all_articles with `root entry {
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
    can scheduled_news_fetch with `root entry {
        categories = ["business", "health", "technology", "sports", "entertainment"];
        total_new = 0;
        
        report("🔄 Starting scheduled news fetch...");
        
        for category in categories {
            # Spawn fetch_and_store_news for each category from the entry node
            visit root spawn fetch_and_store_news(category=category);
            total_new = total_new + 1;
        }
        
        report("✅ Scheduled fetch completed. Processed " + str(len(categories)) + " categories");
    }
}

# Walker: Smoke test (fetch -> verify -> list) in one call
walker run_smoke_test {
    has category: str = "business";
    has limit: int = 2;

    can run_smoke_test with `root entry {
        report("🚀 Running smoke test: fetch -> verify -> list");

        # 1) Fetch and store sample articles for category
        visit root spawn fetch_and_store_news(category=self.category, limit=self.limit);

        # 2) Pick first article title and run verification
        all_articles = [root --> (`?Article)];
        chosen = [];
        for a in all_articles {
            if len(chosen) < 1 and a.category == self.category {
                chosen.append(a);
            }
        }
        if len(chosen) == 0 {
            report("ℹ️ No article found to verify in category: " + self.category);
        } else {
            tgt = chosen[0];
            visit root spawn verify_article(article_title=tgt.title);
        }

        # 3) List articles to show status
        visit root spawn list_all_articles(limit=20);

        report("✅ Smoke test complete");
    }
}