````markdown
# News GAUGE Frontend

A modern frontend application built with Jac and React for user authentication and interaction with the News GAUGE backend.

## Features

- **User Registration**: Create new user accounts with email validation
- **User Login**: Secure authentication with JWT tokens
- **Protected Routes**: Dashboard accessible only to authenticated users
- **Responsive Design**: Mobile-friendly UI with modern styling
- **Jac Client Integration**: Seamless communication with Jac backend

## Project Structure

```
frontend/
├── app.jac                 # Main app with routing
├── src/
│   ├── Login.jac          # Login component
│   ├── Register.jac       # Registration component
│   ├── Dashboard.jac      # Protected dashboard
│   └── client_runtime.js  # Jac client API utilities
├── assets/
│   └── styles.css         # Application styles
├── index.html             # HTML entry point
├── package.json           # Dependencies
└── vite.config.js         # Vite configuration
```

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Backend URL

Edit the `.env` file to set your backend API URL:

```env
VITE_API_URL=http://localhost:8000
```

### 3. Compile Jac Code

Compile your Jac files to JavaScript:

```bash
npm run compile
```

### 4. Run Development Server

Start the Vite development server:

```bash
npm run dev
```

Or use the Jac CLI:

```bash
jac serve app.jac
```

### 5. Build for Production

```bash
npm run build
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run compile` - Compile Jac files to JavaScript
- `npm run build` - Build for production
- `npm run preview` - Preview production build

## API Integration

The frontend communicates with your Jac backend using the `JacClient` class located in `src/client_runtime.js`.

### Expected Backend Endpoints

Your Jac backend should implement these endpoints:

#### POST /user/register
```json
Request:
{
  "username": "string",
  "email": "string",
  "password": "string"
}

Response:
{
  "token": "jwt_token_string",
  "user": {
    "id": "user_id",
    "username": "string",
    "email": "string"
  }
}
```

#### POST /user/login
```json
Request:
{
  "email": "string",
  "password": "string"
}

Response:
{
  "token": "jwt_token_string",
  "user": {
    "id": "user_id",
    "username": "string",
    "email": "string"
  }
}
```

#### GET /user/profile
```json
Headers:
Authorization: Bearer {token}

Response:
{
  "user": {
    "id": "user_id",
    "username": "string",
    "email": "string"
  }
}
```

## Authentication Flow

1. **Registration**: User fills registration form → API call to `/user/register` → Token stored in localStorage → Redirect to dashboard
2. **Login**: User enters credentials → API call to `/user/login` → Token stored in localStorage → Redirect to dashboard
3. **Protected Routes**: Check token in localStorage → If valid, allow access → If invalid, redirect to login
4. **Logout**: Clear token and user data from localStorage → Redirect to login

## Components

### Login Component (`src/Login.jac`)
- Email and password authentication
- Error handling and validation
- Loading states
- Link to registration page

### Register Component (`src/Register.jac`)
- Username, email, and password fields
- Password confirmation
- Client-side validation
- Link to login page

### Dashboard Component (`src/Dashboard.jac`)
- Protected route (requires authentication)
- Displays user information
- Logout functionality

### JacClient (`src/client_runtime.js`)
- API request wrapper
- Token management
- LocalStorage integration
- Authentication helpers

## Customization

### Styling
Edit `assets/styles.css` to customize the look and feel of your application.

### API Endpoints
Modify the endpoint URLs in `src/client_runtime.js` to match your backend structure.

### Add New Features
Create new `.jac` files in the `src/` directory and import them in `app.jac`.

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Troubleshooting

### CORS Issues
Make sure your backend allows requests from your frontend origin. Add CORS headers to your Jac backend.

### Build Errors
If you encounter build errors, try:
```bash
rm -rf node_modules build dist
npm install
npm run compile
```

### Token Issues
Clear browser localStorage and cookies if experiencing authentication issues:
```javascript
localStorage.clear()
```

## Next Steps

- Add password reset functionality
- Implement user profile editing
- Add news article features
- Implement news filtering and preferences
- Add real-time notifications

Happy coding with Jac!

````
