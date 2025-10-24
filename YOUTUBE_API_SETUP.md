# YouTube API Setup Guide for SprintScope

## Overview
This guide will help you set up YouTube Data API v3 to enable direct video uploads from SprintScope to YouTube.

## Prerequisites
1. Google Account
2. Google Cloud Console access
3. Billing enabled on Google Cloud project (required for YouTube API)

## Step-by-Step Setup

### 1. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" > "New Project"
3. Enter project name: `sprintscope-youtube-api`
4. Click "Create"

### 2. Enable YouTube Data API v3
1. In your project, go to "APIs & Services" > "Library"
2. Search for "YouTube Data API v3"
3. Click on it and click "Enable"

### 3. Create OAuth 2.0 Credentials
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client IDs"
3. Configure OAuth consent screen:
   - User Type: External
   - App name: SprintScope
   - User support email: your email
   - Developer contact information: your email
   - Scopes: Add `https://www.googleapis.com/auth/youtube.upload`
4. Create OAuth 2.0 Client ID:
   - Application type: Web application
   - Name: SprintScope Web Client
   - Authorized redirect URIs: `http://localhost:8080/auth/callback`
   - Click "Create"

### 4. Get API Key
1. In "Credentials" page, click "Create Credentials" > "API Key"
2. Copy the API key

### 5. Update SprintScope Configuration
1. Open `lib/services/youtube_service.dart`
2. Update the constants:
```dart
static const String _apiKey = 'YOUR_ACTUAL_API_KEY';
static const String _clientId = 'YOUR_ACTUAL_CLIENT_ID';
static const String _clientSecret = 'YOUR_ACTUAL_CLIENT_SECRET';
static const String _redirectUri = 'http://localhost:8080/auth/callback';
```

### 6. Enable Billing
1. Go to "Billing" in Google Cloud Console
2. Link a billing account to your project
3. YouTube API requires billing to be enabled

## Current Implementation Status

### ✅ What's Working
- Manual YouTube URL input
- YouTube URL validation
- Video thumbnail extraction
- Video ID extraction
- Manual upload instructions

### 🔄 What's Partially Implemented
- YouTube API upload functionality (requires OAuth setup)
- Web platform detection
- Error handling for upload failures

### ❌ What Needs Setup
- OAuth 2.0 authentication flow
- Direct file upload to YouTube
- Access token management
- Token refresh handling

## Usage Instructions

### For Users (Current State)
1. **Manual Upload Method (Recommended)**:
   - Upload video to YouTube manually
   - Copy the YouTube URL
   - Paste it in SprintScope
   - Continue with analysis

2. **Direct Upload Method (Requires API Setup)**:
   - Follow the API setup guide above
   - Configure OAuth credentials
   - Use the file upload feature

### For Developers
1. Complete the OAuth 2.0 implementation in `YouTubeService`
2. Add token storage and refresh logic
3. Implement proper error handling
4. Add upload progress tracking

## Security Considerations
- Never commit API keys to version control
- Use environment variables for sensitive data
- Implement proper token storage
- Add rate limiting for API calls

## Troubleshooting

### Common Issues
1. **"API key not valid"**: Check if API key is correct and YouTube API is enabled
2. **"OAuth consent screen not configured"**: Complete the OAuth consent screen setup
3. **"Billing not enabled"**: Enable billing on your Google Cloud project
4. **"Redirect URI mismatch"**: Ensure redirect URI matches exactly

### Error Messages
- `Failed to get access token`: OAuth not configured
- `Upload failed: 403`: Insufficient permissions or billing not enabled
- `Upload failed: 400`: Invalid request format

## Alternative Approach (Recommended for MVP)
For the initial release, use the manual upload approach:
1. Users upload videos to YouTube manually
2. Copy the YouTube URL
3. Paste it in SprintScope
4. Continue with analysis

This approach:
- ✅ Requires no API setup
- ✅ No billing required
- ✅ Works immediately
- ✅ User-friendly
- ✅ No rate limits

## Next Steps
1. Complete OAuth 2.0 implementation
2. Add upload progress tracking
3. Implement token refresh
4. Add error recovery
5. Test with real videos

## Support
For issues with YouTube API setup, refer to:
- [YouTube Data API v3 Documentation](https://developers.google.com/youtube/v3)
- [Google Cloud Console Help](https://cloud.google.com/docs)
- [OAuth 2.0 Guide](https://developers.google.com/identity/protocols/oauth2) 