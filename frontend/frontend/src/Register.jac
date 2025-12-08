# Register Component
cl import from react {useState}
cl import from "react-router-dom" {useNavigate, Link}
cl import from "@jac-client/utils" {jacClient}

cl {
    def Register() -> any {
        let [formData, setFormData] = useState({
            username: "",
            email: "",
            password: "",
            confirmPassword: ""
        });
        let [error, setError] = useState("");
        let [loading, setLoading] = useState(false);
        let navigate = useNavigate();

        let handleChange = lambda e: any -> None {
            let {name, value} = e.target;
            setFormData({
                ...formData,
                [name]: value
            });
        };

        let handleSubmit = lambda e: any -> None {
            e.preventDefault();
            setError("");
            setLoading(true);

            # Validate inputs
            if (!formData.username || !formData.email || !formData.password || !formData.confirmPassword) {
                setError("Please fill in all fields");
                setLoading(false);
                return;
            }

            # Check password match
            if (formData.password !== formData.confirmPassword) {
                setError("Passwords do not match");
                setLoading(false);
                return;
            }

            # Check password length
            if (formData.password.length < 6) {
                setError("Password must be at least 6 characters long");
                setLoading(false);
                return;
            }

            # Call register API
            jacClient.register({
                username: formData.username,
                email: formData.email,
                password: formData.password
            })
            .then(lambda response: any -> None {
                console.log("Registration successful:", response);
                setLoading(false);
                navigate("/dashboard");
            })
            .catch(lambda err: any -> None {
                console.error("Registration error:", err);
                setError(err.message || "Registration failed. Please try again.");
                setLoading(false);
            });
        };

        return <div className="auth-container">
            <div className="auth-card">
                <h2>Register for News GAUGE</h2>
                <form onSubmit={handleSubmit} className="auth-form">
                    {error && <div className="error-message">{error}</div>}
                    
                    <div className="form-group">
                        <label htmlFor="username">Username</label>
                        <input
                            type="text"
                            id="username"
                            name="username"
                            value={formData.username}
                            onChange={handleChange}
                            placeholder="Choose a username"
                            disabled={loading}
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label htmlFor="email">Email</label>
                        <input
                            type="email"
                            id="email"
                            name="email"
                            value={formData.email}
                            onChange={handleChange}
                            placeholder="Enter your email"
                            disabled={loading}
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label htmlFor="password">Password</label>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            value={formData.password}
                            onChange={handleChange}
                            placeholder="Create a password (min 6 characters)"
                            disabled={loading}
                            required
                        />
                    </div>

                    <div className="form-group">
                        <label htmlFor="confirmPassword">Confirm Password</label>
                        <input
                            type="password"
                            id="confirmPassword"
                            name="confirmPassword"
                            value={formData.confirmPassword}
                            onChange={handleChange}
                            placeholder="Confirm your password"
                            disabled={loading}
                            required
                        />
                    </div>

                    <button type="submit" className="btn btn-primary" disabled={loading}>
                        {loading ? "Creating Account..." : "Register"}
                    </button>
                </form>

                <p className="auth-link">
                    Already have an account? <Link to="/login">Login here</Link>
                </p>
            </div>
        </div>;
    }
}
