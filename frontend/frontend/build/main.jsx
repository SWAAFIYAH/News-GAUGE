import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { jacClient } from './client_runtime.js';

// Simple auth check component
function ProtectedRoute({ children }) {
    if (!jacClient.isAuthenticated()) {
        return <Navigate to="/login" replace />;
    }
    return children;
}

// Placeholder components until we can compile the Jac files
function Login() {
    const [username, setUsername] = React.useState('');
    const [password, setPassword] = React.useState('');
    const [error, setError] = React.useState('');
    const [loading, setLoading] = React.useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        if (!username || !password) {
            setError('Please fill in all fields');
            setLoading(false);
            return;
        }

        try {
            const response = await jacClient.login({ username, password });
            console.log('Login successful:', response);
            window.location.href = '/dashboard';
        } catch (err) {
            console.error('Login error:', err);
            setError(err.message || 'Login failed. Please check your credentials.');
            setLoading(false);
        }
    };

    return (
        <div className="auth-container">
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
                            onChange={(e) => setUsername(e.target.value)}
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
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="Enter your password"
                            disabled={loading}
                            required
                        />
                    </div>

                    <button type="submit" className="btn btn-primary" disabled={loading}>
                        {loading ? 'Logging in...' : 'Login'}
                    </button>
                </form>

                <p className="auth-link">
                    Don't have an account? <a href="/register">Register here</a>
                </p>
            </div>
        </div>
    );
}

function Register() {
    const [formData, setFormData] = React.useState({
        username: '',
        email: '',
        password: '',
        confirmPassword: ''
    });
    const [error, setError] = React.useState('');
    const [loading, setLoading] = React.useState(false);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData({ ...formData, [name]: value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        if (!formData.username || !formData.email || !formData.password || !formData.confirmPassword) {
            setError('Please fill in all fields');
            setLoading(false);
            return;
        }

        if (formData.password !== formData.confirmPassword) {
            setError('Passwords do not match');
            setLoading(false);
            return;
        }

        if (formData.password.length < 6) {
            setError('Password must be at least 6 characters long');
            setLoading(false);
            return;
        }

        try {
            const response = await jacClient.register({
                username: formData.username,
                email: formData.email,
                password: formData.password
            });
            console.log('Registration successful:', response);
            window.location.href = '/login';
        } catch (err) {
            console.error('Registration error:', err);
            setError(err.message || 'Registration failed. Please try again.');
            setLoading(false);
        }
    };

    return (
        <div className="auth-container">
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
                        {loading ? 'Creating Account...' : 'Register'}
                    </button>
                </form>

                <p className="auth-link">
                    Already have an account? <a href="/login">Login here</a>
                </p>
            </div>
        </div>
    );
}

function Dashboard() {
    const [articles, setArticles] = React.useState([]);
    const [loading, setLoading] = React.useState(false);
    const [selectedCategory, setSelectedCategory] = React.useState(null);
    const [message, setMessage] = React.useState('Welcome! Select a category or click "Show All Articles" to view news.');

    const categories = ['technology', 'business', 'sports', 'entertainment', 'health', 'science'];

    React.useEffect(() => {
        // Don't load articles on mount - wait for user action
    }, []);

    const loadArticles = async () => {
        setLoading(true);
        setMessage('');
        try {
            const response = await jacClient.listAllArticles();
            console.log('Articles response:', response);
            if (response.reports && response.reports.length > 0) {
                setArticles(response.reports);
                setMessage(`Loaded ${response.reports.length} articles`);
            } else {
                setArticles([]);
                setMessage('No articles found. Click "Fetch New Articles" to get some.');
            }
        } catch (err) {
            console.error('Failed to load articles:', err);
            setMessage('Error loading articles: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    const fetchNewArticles = async () => {
        setLoading(true);
        setMessage('Fetching new articles...');
        try {
            const response = await jacClient.fetchAndStoreNews();
            console.log('Fetch response:', response);
            setMessage('Successfully fetched new articles!');
            // Reload the articles list
            await loadArticles();
        } catch (err) {
            console.error('Failed to fetch articles:', err);
            setMessage('Error fetching articles: ' + err.message);
            setLoading(false);
        }
    };

    const filterByCategory = async (category) => {
        setSelectedCategory(category);
        setLoading(true);
        setMessage('');
        try {
            const response = await jacClient.getNewsByCategory(category);
            console.log('Category response:', response);
            if (response.reports && response.reports.length > 0) {
                setArticles(response.reports);
                setMessage(`Found ${response.reports.length} articles in ${category}`);
            } else {
                setArticles([]);
                setMessage(`No articles found in ${category} category`);
            }
        } catch (err) {
            console.error('Failed to filter articles:', err);
            setMessage('Error filtering articles: ' + err.message);
        } finally {
            setLoading(false);
        }
    };

    const showAllArticles = async () => {
        setSelectedCategory('all');
        await loadArticles();
    };

    const handleLogout = () => {
        jacClient.logout();
        window.location.href = '/login';
    };

    const verifyArticle = async (articleTitle) => {
        setMessage('Verifying article: ' + articleTitle + '...');
        try {
            const response = await jacClient.verifyArticle(articleTitle);
            console.log('Verification response:', response);
            setMessage(response.reports ? response.reports[0] : 'Article verified');
            // Reload articles to show updated verification status
            await loadArticles();
        } catch (err) {
            console.error('Failed to verify article:', err);
            setMessage('Error verifying article: ' + err.message);
        }
    };

    return (
        <div className="dashboard-container">
            <div className="dashboard-header">
                <h1>News GAUGE Dashboard</h1>
                <button onClick={handleLogout} className="btn btn-secondary">Logout</button>
            </div>
            
            <div className="dashboard-controls">
                <button 
                    onClick={fetchNewArticles} 
                    className="btn btn-primary"
                    disabled={loading}
                >
                    {loading ? 'Fetching...' : 'Fetch New Articles'}
                </button>
                
                <button 
                    onClick={showAllArticles} 
                    className="btn btn-primary"
                    disabled={loading}
                >
                    Show All Articles
                </button>
                
                <div className="category-filters">
                    <h3>Filter by Category:</h3>
                    <div className="category-buttons">
                        {categories.map((cat) => (
                            <button
                                key={cat}
                                onClick={() => filterByCategory(cat)}
                                className={`btn ${selectedCategory === cat ? 'btn-active' : 'btn-outline'}`}
                                disabled={loading}
                            >
                                {cat.charAt(0).toUpperCase() + cat.slice(1)}
                            </button>
                        ))}
                    </div>
                </div>
            </div>
            
            {message && <div className="message-box">{message}</div>}
            
            <div className="dashboard-content">
                <h2>Articles {selectedCategory && selectedCategory !== 'all' ? `- ${selectedCategory}` : ''}</h2>
                {loading ? (
                    <p>Loading articles...</p>
                ) : articles.length > 0 ? (
                    <div className="articles-list">
                        {articles.map((article, index) => (
                            <div key={index} className="article-card">
                                {typeof article === 'string' ? (
                                    <p>{article}</p>
                                ) : (
                                    <>
                                        <div className="article-header">
                                            <h3>{article.title || 'Untitled'}</h3>
                                            {article.verified && (
                                                <span className="verified-badge" title={`Credibility: ${article.credibility_score || 'N/A'}`}>
                                                    ✓ Verified
                                                </span>
                                            )}
                                        </div>
                                        {article.category && <span className="category-badge">{article.category}</span>}
                                        <p>{article.description || article.content || 'No description available'}</p>
                                        {article.source && <p className="article-source">Source: {article.source}</p>}
                                        {article.credibility_score && (
                                            <p className="credibility-score">
                                                Credibility Score: {(article.credibility_score * 100).toFixed(0)}%
                                            </p>
                                        )}
                                        <div className="article-actions">
                                            {article.url && <a href={article.url} target="_blank" rel="noopener noreferrer">Read more →</a>}
                                            <button 
                                                onClick={() => verifyArticle(article.title)}
                                                className="btn btn-verify"
                                                disabled={loading}
                                            >
                                                {article.verified ? 'Re-verify' : 'Verify'}
                                            </button>
                                        </div>
                                    </>
                                )}
                            </div>
                        ))}
                    </div>
                ) : (
                    <p>No articles found</p>
                )}
            </div>
        </div>
    );
}

// Main App
function App() {
    return (
        <Router>
            <div className="app">
                <Routes>
                    <Route path="/" element={<Navigate to="/login" replace />} />
                    <Route path="/login" element={<Login />} />
                    <Route path="/register" element={<Register />} />
                    <Route 
                        path="/dashboard" 
                        element={
                            <ProtectedRoute>
                                <Dashboard />
                            </ProtectedRoute>
                        } 
                    />
                    <Route path="*" element={<Navigate to="/login" replace />} />
                </Routes>
            </div>
        </Router>
    );
}

// Mount app
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
