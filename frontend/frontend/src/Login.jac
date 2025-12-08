# Login Component
cl import from react {useState}
cl import from "react-router-dom" {useNavigate, Link}
cl import from "@jac-client/utils" {jacClient}

cl {
    def Login() -> any {
        let [username, setUsername] = useState("");
        let [password, setPassword] = useState("");
        let [error, setError] = useState("");
        let [loading, setLoading] = useState(false);
        let navigate = useNavigate();

        let handleSubmit = lambda e: any -> None {
            e.preventDefault();
            setError("");
            setLoading(true);

            # Validate inputs
            if (!username || !password) {
                setError("Please fill in all fields");
                setLoading(false);
                return;
            }

            # Call login API
            jacClient.login({
                username: username,
                password: password
            })
            .then(lambda response: any -> None {
                console.log("Login successful:", response);
                setLoading(false);
                navigate("/dashboard");
            })
            .catch(lambda err: any -> None {
                console.error("Login error:", err);
                setError(err.message || "Login failed. Please check your credentials.");
                setLoading(false);
            });
        };

        return <div className="auth-container">
            <div className="auth-card">
                <h2>Login to News GAUGE</h2>
                <form onSubmit={handleSubmit} className="auth-form">
                    {error && <div className="error-message">{error}</div>}
                    
                    <div className="form-group">
                        <label htmlFor="username">Username</label>
                        <input
                            type="text"
                            id="username"
                            value={username}
                            onChange={lambda e: any -> None {setUsername(e.target.value);}}
                            placeholder="Enter your username"
                            disabled={loading}
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label htmlFor="password">Password</label>
                        <input
                            type="password"
                            id="password"
                            value={password}
                            onChange={lambda e: any -> None {setPassword(e.target.value);}}
                            placeholder="Enter your password"
                            disabled={loading}
                            required
                        />
                    </div>

                    <button type="submit" className="btn btn-primary" disabled={loading}>
                        {loading ? "Logging in..." : "Login"}
                    </button>
                </form>

                <p className="auth-link">
                    Don't have an account? <Link to="/register">Register here</Link>
                </p>
            </div>
        </div>;
    }
}
