# Dashboard Component - Protected route
cl import from react {useState, useEffect}
cl import from "react-router-dom" {useNavigate}
cl import from "@jac-client/utils" {jacClient}

cl {
    def Dashboard() -> any {
        let [user, setUser] = useState(null);
        let [loading, setLoading] = useState(true);
        let navigate = useNavigate();

        useEffect(lambda -> None {
            # Check if user is authenticated
            if (!jacClient.isAuthenticated()) {
                navigate("/login");
                return;
            }

            # Get user data
            let userData = jacClient.getUserData();
            if (userData) {
                setUser(userData);
                setLoading(false);
            } else {
                # Try to fetch user profile
                jacClient.getProfile()
                    .then(lambda response: any -> None {
                        setUser(response.user);
                        setLoading(false);
                    })
                    .catch(lambda err: any -> None {
                        console.error("Failed to fetch profile:", err);
                        jacClient.logout();
                        navigate("/login");
                    });
            }
        }, []);

        let handleLogout = lambda -> None {
            jacClient.logout();
            navigate("/login");
        };

        if (loading) {
            return <div className="dashboard-container">
                <div className="loading">Loading...</div>
            </div>;
        }

        return <div className="dashboard-container">
            <div className="dashboard-header">
                <h1>News GAUGE Dashboard</h1>
                <button onClick={handleLogout} className="btn btn-secondary">
                    Logout
                </button>
            </div>
            <div className="dashboard-content">
                <div className="welcome-card">
                    <h2>Welcome, {user?.username || user?.email}!</h2>
                    <p>You have successfully logged into News GAUGE.</p>
                    <div className="user-info">
                        <p><strong>Email:</strong> {user?.email}</p>
                        {user?.username && <p><strong>Username:</strong> {user?.username}</p>}
                    </div>
                </div>
            </div>
        </div>;
    }
}
