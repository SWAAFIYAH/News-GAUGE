// Jac Client Runtime - API utilities for communicating with Jac backend (using Jac walkers)

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

/**
 * Wrapper for making API calls to Jac backend via the `/walker` endpoints.
 * The frontend components were already written to use a `jacClient`; this
 * implementation maps common actions to the existing Jac walkers.
 */
export class JacClient {
    constructor(baseURL = API_BASE_URL) {
        this.baseURL = baseURL;
        this.token = localStorage.getItem('jac_token') || null;
    }

    setToken(token) {
        this.token = token;
        if (token) localStorage.setItem('jac_token', token);
        else localStorage.removeItem('jac_token');
    }

    getToken() {
        return this.token;
    }

    isAuthenticated() {
        return !!this.token;
    }

    logout() {
        this.token = null;
        localStorage.removeItem('jac_token');
        localStorage.removeItem('user_data');
    }

    async requestWalker(walkerName, payload = {}) {
        // Jac cloud exposes walkers under /walker/<name>
        const url = `${this.baseURL}/walker/${walkerName}`;
        const headers = {
            'Content-Type': 'application/json',
        };

        if (this.token) headers['Authorization'] = `Bearer ${this.token}`;

        const res = await fetch(url, {
            method: 'POST',
            headers,
            body: JSON.stringify(payload),
        });

        let data;
        try {
            data = await res.json();
        } catch (e) {
            throw new Error('Invalid JSON response from server');
        }

        if (!res.ok) {
            const msg = data.message || data.error || `Walker ${walkerName} failed`;
            throw new Error(msg);
        }

        return data;
    }

    // Register / create or update user using existing walker
    async register({username, email, password}) {
        // The backend walker is `update_user` and expects `username` and `password`.
        const payload = { username, password, email };
        const res = await this.requestWalker('update_user', payload);

        // Check for token in response
        if (res.reports && res.reports.length > 0 && res.reports[0].token) {
            this.setToken(res.reports[0].token);
            localStorage.setItem('user_data', JSON.stringify({ username: res.reports[0].username }));
        }
        
        return res;
    }

    // Login via walker
    async login(credentials) {
        // backend expects `username` and `password`.
        const username = credentials.username || credentials.email;
        const payload = { username, password: credentials.password };
        const res = await this.requestWalker('login_user', payload);

        // Check for token in response
        if (res.reports && res.reports.length > 0 && res.reports[0].token) {
            this.setToken(res.reports[0].token);
            localStorage.setItem('user_data', JSON.stringify({ username: res.reports[0].username }));
        }
        
        return res;
    }

    // News related helpers
    async fetchAndStoreNews({ category = 'general', limit = 10, api_key = '' } = {}) {
        return await this.requestWalker('fetch_and_store_news', { category, limit, api_key });
    }

    async listAllArticles() {
        return await this.requestWalker('list_all_articles', {});
    }

    async getNewsByCategory(category) {
        return await this.requestWalker('get_news_by_category', { category });
    }

    async verifyArticle(article_title) {
        return await this.requestWalker('verify_article', { article_title });
    }

    getUserData() {
        const userData = localStorage.getItem('user_data');
        return userData ? JSON.parse(userData) : null;
    }
}

export const jacClient = new JacClient();
