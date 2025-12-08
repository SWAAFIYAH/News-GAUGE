"""
Jac Frontend Application Structure
Demonstrates Jac language usage for frontend routing and UI rendering
"""

# Node representing different pages/views
node PageView {
    has name: str;
    has title: str;
    has html_template: str;
}

# Walker to initialize app pages
walker InitializePages {
    can create_pages with `root entry {
        # Create Login page
        login_page = here ++> PageView(
            name="login",
            title="Login to News GAUGE",
            html_template="<div class='auth-container'><h2>Login Page</h2></div>"
        );
        
        # Create Register page
        register_page = here ++> PageView(
            name="register",
            title="Register for News GAUGE",
            html_template="<div class='auth-container'><h2>Register Page</h2></div>"
        );
        
        # Create Dashboard page
        dashboard_page = here ++> PageView(
            name="dashboard",
            title="News GAUGE Dashboard",
            html_template="<div class='dashboard-container'><h2>Dashboard</h2></div>"
        );
        
        report "✅ Initialized 3 frontend pages: login, register, dashboard";
    }
}

# Walker for page navigation
walker NavigateToPage {
    has page_name: str;
    
    can navigate with `root entry {
        # Find all pages
        pages = [here --> (`?PageView)];
        target_page = [p for p in pages if p.name == self.page_name];
        
        if len(target_page) > 0 {
            page = target_page[0];
            report {
                "success": True,
                "page": page.name,
                "title": page.title,
                "template": page.html_template
            };
        } else {
            report {
                "success": False,
                "error": "Page not found: " + self.page_name
            };
        }
    }
}

# Walker to render page content
walker RenderPage {
    has page_name: str;
    has data: dict = {};
    
    can render with `root entry {
        # Navigate to page first
        nav = spawn NavigateToPage(page_name=self.page_name);
        visit nav;
        report "📄 Rendering page: " + self.page_name;
    }
}

# Initialize frontend application
with entry {
    init = spawn InitializePages();
    visit init;
}
