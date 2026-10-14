# Aureline Hotel Mobile App - Backend Integration

This document explains how to set up and run the Flutter mobile app connected to the web app's backend.

## Prerequisites

1. **Backend Server Running**: The web app backend (Hotel-Management) must be running with MongoDB configured.
2. **Flutter SDK**: Ensure Flutter is installed on your development machine.
3. **Environment Variables**: Backend must have the following configured:
   - `MONGO_URI`: MongoDB connection string
   - `MONGODB_DB_NAME`: Database name (default: hotel-management)
   - `JWT_SECRET`: Secret for JWT token generation
   - `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_USER`, `EMAIL_PASS`: SMTP configuration for OTP emails

## Setup Instructions

### 1. Install Dependencies

Navigate to the mobile app directory and install dependencies:

```bash
cd Hotel-Management-Mobile/aureline-flutter-mobile
flutter pub get
```

### 2. Configure API Base URL

Create a `.env` file in the mobile app root directory:

```bash
# For local development
API_BASE_URL=http://localhost:5000

# For production/deployment, use your actual backend URL
# API_BASE_URL=https://your-backend-domain.com
```

A `.env.example` file is provided as a template.

### 3. Backend Server

Ensure the backend server is running. From the Hotel-Management directory:

```bash
# Using the serverless API (recommended for production/Vercel)
cd Hotel-Management
npm start

# Or using the traditional server
node server.js
```

The backend should be accessible at the URL specified in your mobile app's `.env` file.

## Features Implemented

### Guest Authentication

The mobile app now connects to the same backend as the web app and supports:

1. **Guest Sign Up**:
   - First name validation (2+ characters, letters/spaces/hyphens/apostrophes only)
   - Last name validation (2+ characters, letters/spaces/hyphens/apostrophes only)
   - Email validation (valid email format, 5+ characters)
   - Password validation (8+ characters)
   - Password confirmation matching
   - Email OTP verification before account creation

2. **Guest Login**:
   - Email validation (valid email format)
   - Password validation (8+ characters)
   - Email OTP verification if 2FA is enabled
   - JWT token storage for persistent sessions

3. **Session Management**:
   - Tokens stored securely using SharedPreferences
   - Automatic session restoration on app launch
   - Sign out functionality that clears stored credentials

### API Endpoints Used

The mobile app communicates with the following backend endpoints:

- `POST /api/auth/login` - Authenticate user
- `POST /api/auth/register` - Create new guest account (after OTP verification)
- `POST /api/otp/send` - Request OTP for email verification
- `POST /api/otp/verify` - Verify OTP code
- `GET /api/profile` - Get user profile (authenticated)

### Role Restrictions

**Important**: The mobile app only allows **Guest** role authentication. Admin and Staff accounts are restricted to the web interface.

## File Structure

New files added:

```
lib/
├── services/
│   ├── api_service.dart          # HTTP client wrapper for API calls
│   ├── auth_service.dart         # Authentication-specific API methods
│   └── account_store.dart        # Updated with real backend integration
└── core/
    └── constants/
        └── app_constants.dart    # Added AppConfig for API base URL
```

Modified files:

```
lib/
├── main.dart                     # Added dotenv loading and AccountStore initialization
├── presentation/screens/
│   ├── sign_in_screen.dart       # Added validation and OTP flow
│   └── sign_up_screen.dart       # Added validation and OTP flow
```

## Running the App

### Development Mode

```bash
flutter run
```

### Build for Android

```bash
flutter build apk
```

### Build for iOS

```bash
flutter build ios
```

## Testing the Authentication Flow

1. **Sign Up Flow**:
   - Navigate to sign-up screen
   - Enter valid first name, last name, email, and password
   - Confirm password
   - Click "Create guest account"
   - Check your email for the 6-digit OTP code
   - Enter the OTP code
   - Account is created and you're automatically signed in

2. **Login Flow**:
   - Navigate to sign-in screen
   - Enter your email and password
   - Click "Sign in"
   - If 2FA is enabled, enter the OTP code sent to your email
   - You're now authenticated and can access guest features

## Troubleshooting

### Connection Refused / Network Error

- Ensure the backend server is running
- Check that the `API_BASE_URL` in `.env` matches your backend server address
- For local development with Android emulator, use `http://10.0.2.2:5000` instead of `localhost`
- For iOS simulator, `localhost` should work

### OTP Not Received

- Check backend email configuration (EMAIL_HOST, EMAIL_PORT, EMAIL_USER, EMAIL_PASS)
- Verify spam/junk folders
- Check backend logs for email sending errors

### Invalid/Expired OTP

- OTP codes expire after 1 minute
- Request a new OTP if needed
- Ensure the correct email address is being used

### Build Errors

- Run `flutter clean` then `flutter pub get`
- Ensure all dependencies are properly installed
- Check Flutter SDK version compatibility

## Security Notes

- Tokens are stored locally using SharedPreferences
- In production, consider using more secure storage (flutter_secure_storage)
- Always use HTTPS in production environments
- Ensure backend JWT_SECRET is properly configured and kept secret
- Backend validates that only Guest role can authenticate via mobile

## Future Enhancements

Consider adding:
- Password reset flow
- Profile editing
- Reservation management
- Room booking
- Push notifications
- Biometric authentication
