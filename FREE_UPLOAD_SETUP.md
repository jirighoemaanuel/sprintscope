# Free Video Upload Setup Guide

## 🚀 **Automatic Video Upload Solution**

This guide will help you set up **free video upload services** so users can automatically upload videos and get URLs without any manual steps.

## **Option 1: Cloudinary (Recommended)**

### **Why Cloudinary?**
- ✅ **Free tier**: 25GB storage, 25GB bandwidth/month
- ✅ **Easy setup**: No complex OAuth required
- ✅ **Fast uploads**: Direct API integration
- ✅ **Video support**: Full video hosting and streaming

### **Setup Steps:**

1. **Sign up for Cloudinary:**
   - Go to [https://cloudinary.com/](https://cloudinary.com/)
   - Click "Sign Up For Free"
   - Create your account

2. **Get your credentials:**
   - After signing up, go to your Dashboard
   - Copy your **Cloud Name**
   - Copy your **API Key**
   - Copy your **API Secret**

3. **Update SprintScope:**
   - Open `lib/services/video_upload_service.dart`
   - Update these lines:
   ```dart
   static const String _cloudinaryCloudName = 'YOUR_CLOUDINARY_CLOUD_NAME';
   static const String _cloudinaryApiKey = 'YOUR_CLOUDINARY_API_KEY';
   static const String _cloudinaryApiSecret = 'YOUR_CLOUDINARY_API_SECRET';
   ```

4. **Test the upload:**
   - Run the app
   - Try uploading a video
   - It should automatically upload to Cloudinary and return a URL

## **Option 2: ImgBB (Alternative)**

### **Why ImgBB?**
- ✅ **Free tier**: 32MB per image/video
- ✅ **Simple API**: Easy to integrate
- ✅ **No registration**: Just get an API key

### **Setup Steps:**

1. **Get API Key:**
   - Go to [https://api.imgbb.com/](https://api.imgbb.com/)
   - Click "Get API Key"
   - Copy your API key

2. **Update SprintScope:**
   - Open `lib/services/video_upload_service.dart`
   - Update this line:
   ```dart
   static const String _imgbbApiKey = 'YOUR_IMGBB_API_KEY';
   ```

## **Option 3: YouTube API (Advanced)**

### **Why YouTube API?**
- ✅ **Unlimited storage**: YouTube's infrastructure
- ✅ **Familiar platform**: Users know YouTube
- ❌ **Complex setup**: Requires OAuth 2.0
- ❌ **Billing required**: Google Cloud billing needed

### **Setup Steps:**
Follow the `YOUTUBE_API_SETUP.md` guide for detailed instructions.

## **How It Works**

### **Current Implementation:**
1. User selects video file
2. App stores video bytes in memory
3. App tries to upload to configured services in order:
   - Cloudinary (if configured)
   - ImgBB (if configured)
   - YouTube (if configured)
4. Returns the video URL
5. Stores URL in Firebase database

### **User Experience:**
1. User clicks "Upload Video"
2. Selects video file
3. App automatically uploads to cloud storage
4. Gets back a URL
5. Continues to analysis

## **Testing the Setup**

### **Before Setup:**
- Users see "Setup Required" dialog
- Manual upload instructions shown
- No automatic upload available

### **After Setup:**
- Users can upload videos automatically
- URLs are generated and stored
- Videos are accessible in analysis

## **Security Considerations**

### **API Keys:**
- Never commit API keys to version control
- Use environment variables in production
- Rotate keys regularly

### **File Size Limits:**
- Cloudinary: 100MB per file (free tier)
- ImgBB: 32MB per file
- YouTube: 128GB per file

## **Troubleshooting**

### **Common Issues:**

1. **"Setup Required" dialog appears:**
   - API keys not configured
   - Check the constants in `video_upload_service.dart`

2. **"Upload failed" error:**
   - Check API key validity
   - Check file size limits
   - Check internet connection

3. **"No URL returned" error:**
   - Service might be down
   - Check service status
   - Try alternative service

### **Error Messages:**
- `Cloudinary upload failed`: Check Cloudinary credentials
- `ImgBB upload failed`: Check ImgBB API key
- `All upload services failed`: No services configured

## **Production Deployment**

### **Environment Variables:**
For production, use environment variables instead of hardcoded keys:

```dart
static const String _cloudinaryCloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
static const String _cloudinaryApiKey = String.fromEnvironment('CLOUDINARY_API_KEY');
static const String _cloudinaryApiSecret = String.fromEnvironment('CLOUDINARY_API_SECRET');
```

### **Build Commands:**
```bash
flutter build web --dart-define=CLOUDINARY_CLOUD_NAME=your_cloud_name --dart-define=CLOUDINARY_API_KEY=your_api_key
```

## **Next Steps**

1. **Choose a service** (Cloudinary recommended)
2. **Follow setup steps** above
3. **Test with a small video**
4. **Deploy to production**
5. **Monitor usage** and costs

## **Support**

- **Cloudinary**: [https://cloudinary.com/documentation](https://cloudinary.com/documentation)
- **ImgBB**: [https://api.imgbb.com/](https://api.imgbb.com/)
- **YouTube API**: [https://developers.google.com/youtube/v3](https://developers.google.com/youtube/v3)

## **Cost Comparison**

| Service | Free Tier | Paid Plans |
|---------|-----------|------------|
| Cloudinary | 25GB storage, 25GB bandwidth | $89/month |
| ImgBB | 32MB per file | Free only |
| YouTube | Unlimited | Free |

**Recommendation**: Start with Cloudinary for the best balance of features and ease of setup. 