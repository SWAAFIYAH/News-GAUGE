"""
Jac Frontend Wrapper for News-GAUGE
This demonstrates Jac language usage in the frontend by wrapping
the React components with Jac logic for routing and state management.
"""

# Define frontend state management using Jac nodes
node AppState {
    has is_authenticated: bool = False;
    has current_user: str = "";
    has current_view: str = "login";
    has articles: list = [];
    has selected_category: str = "";
}

# Define navigation actions using Jac walkers
walker NavigateToLogin {
    can navigate with AppState entry {
        here.current_view = "login";
        report "Navigated to login";
    }
}

walker NavigateToRegister {
    can navigate with AppState entry {
        here.current_view = "register";
        report "Navigated to register";
    }
}

walker NavigateToDashboard {
    can navigate with AppState entry {
        if here.is_authenticated {
            here.current_view = "dashboard";
            report "Navigated to dashboard";
        } else {
            here.current_view = "login";
            report "Authentication required - redirected to login";
        }
    }
}

# Walker for user authentication
walker AuthenticateUser {
    has username: str;
    has token: str;
    
    can authenticate with AppState entry {
        here.is_authenticated = True;
        here.current_user = self.username;
        report "User authenticated: " + self.username;
    }
}

# Walker for logout
walker LogoutUser {
    can logout with AppState entry {
        here.is_authenticated = False;
        here.current_user = "";
        here.current_view = "login";
        here.articles = [];
        report "User logged out";
    }
}

# Walker for loading articles
walker LoadArticles {
    has articles_data: list;
    
    can load with AppState entry {
        here.articles = self.articles_data;
        report "Loaded " + str(len(self.articles_data)) + " articles";
    }
}

# Walker for filtering by category
walker FilterByCategory {
    has category: str;
    
    can filter with AppState entry {
        here.selected_category = self.category;
        report "Filtering by category: " + self.category;
    }
}

# Main application controller
walker AppController {
    has action: str;
    has payload: dict = {};
    
    can execute with AppState entry {
        if self.action == "login" {
            auth_walker = spawn AuthenticateUser(
                username=self.payload.get("username", ""),
                token=self.payload.get("token", "")
            );
            visit auth_walker;
            
            nav_walker = spawn NavigateToDashboard();
            visit nav_walker;
        } elif self.action == "logout" {
            logout_walker = spawn LogoutUser();
            visit logout_walker;
        } elif self.action == "load_articles" {
            load_walker = spawn LoadArticles(
                articles_data=self.payload.get("articles", [])
            );
            visit load_walker;
        } elif self.action == "filter_category" {
            filter_walker = spawn FilterByCategory(
                category=self.payload.get("category", "")
            );
            visit filter_walker;
        }
        
        report {
            "view": here.current_view,
            "authenticated": here.is_authenticated,
            "user": here.current_user,
            "articles_count": len(here.articles),
            "category": here.selected_category
        };
    }
}

# Root node initialization
node Root {
    has app_state: AppState;
}

# Initialize application
with entry {
    # Create root node with initial app state
    root ++> Root(app_state=AppState());
}
