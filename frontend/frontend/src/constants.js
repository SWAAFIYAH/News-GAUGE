// Application constants and configuration

export const ROUTES = {
    HOME: '/',
    LOGIN: '/login',
    REGISTER: '/register',
    DASHBOARD: '/dashboard',
};

export const STORAGE_KEYS = {
    TOKEN: 'jac_token',
    USER_DATA: 'user_data',
};

export const API_ENDPOINTS = {
    REGISTER: '/user/register',
    LOGIN: '/user/login',
    PROFILE: '/user/profile',
};

export const ERROR_MESSAGES = {
    NETWORK_ERROR: 'Network error. Please check your connection.',
    AUTH_FAILED: 'Authentication failed. Please check your credentials.',
    REGISTRATION_FAILED: 'Registration failed. Please try again.',
    REQUIRED_FIELDS: 'Please fill in all fields',
    PASSWORD_MISMATCH: 'Passwords do not match',
    PASSWORD_LENGTH: 'Password must be at least 6 characters long',
    INVALID_EMAIL: 'Please enter a valid email address',
};

export const SUCCESS_MESSAGES = {
    LOGIN_SUCCESS: 'Login successful!',
    REGISTRATION_SUCCESS: 'Registration successful!',
    LOGOUT_SUCCESS: 'Logged out successfully',
};
