# Cloudinary Setup Guide for SprintScope

This guide will help you set up Cloudinary for automatic video uploads in SprintScope.

## 🚀 Quick Setup

### 1. Create Cloudinary Account
1. Go to [Cloudinary](https://cloudinary.com) and click "Sign Up For Free"
2. Fill in your details and create your account
3. Verify your email address

### 2. Get Your Credentials
1. After logging in, go to your **Dashboard**
2. Note your **Cloud Name** (found in the URL: `https://cloudinary.com/console`)
3. Go to **Settings** > **Access Keys**
4. Copy your **API Key** and **API Secret**

### 3. Update the Code
1. Open `lib/services/video_upload_service.dart`
2. Replace the placeholder values with your actual credentials:

```dart
// Cloudinary configuration
static const String _cloudName = 'YOUR_ACTUAL_CLOUD_NAME';
static const String _apiKey = 'YOUR_ACTUAL_API_KEY';
static const String _apiSecret = 'YOUR_ACTUAL_API_SECRET';
```

### 4. Install Dependencies
Run this command to install the required crypto package:
```bash
flutter pub get
```

### 5. Restart the App
Restart your Flutter app for the changes to take effect.

## 📋 What You Get

### Free Tier Benefits
- **25GB Storage** - Store thousands of sprint videos
- **25GB Bandwidth** - Serve videos to your athletes
- **Automatic Optimization** - Videos are optimized for web/mobile
- **CDN Delivery** - Fast global video delivery
- **No Credit Card Required** - Completely free to start

### Features
- **Automatic Upload** - Videos upload directly to Cloudinary
- **Thumbnail Generation** - Automatic video thumbnails
- **Video Optimization** - Automatic compression and format conversion
- **Secure URLs** - HTTPS video delivery
- **Organized Storage** - Videos stored in `sprintscope_videos` folder

## 🔧 Advanced Configuration

### Custom Upload Settings
You can customize the upload parameters in `VideoUploadService`:

```dart
final params = {
  'file': 'data:video/mp4;base64,$base64Video',
  'public_id': _generatePublicId(fileName),
  'resource_type': 'video',
  'folder': 'sprintscope_videos', // Custom folder
  'tags': 'sprint,analysis,coaching', // Custom tags
  'context': 'title=${title ?? fileName}', // Custom metadata
};
```

### Video Transformations
Cloudinary supports automatic video transformations:

```dart
// Generate thumbnail
String getThumbnailUrl(String publicId) {
  return 'https://res.cloudinary.com/$_cloudName/video/upload/w_300,h_200,c_fill/$publicId';
}

// Optimized video URL
String getOptimizedVideoUrl(String publicId) {
  return 'https://res.cloudinary.com/$_cloudName/video/upload/f_auto,q_auto/$publicId';
}
```

## 🛠️ Troubleshooting

### Common Issues

**1. "Cloudinary not configured" error**
- Make sure you've updated all three constants in `VideoUploadService`
- Check that your credentials are correct
- Restart the app after making changes

**2. Upload fails with 401 error**
- Verify your API Key and API Secret are correct
- Make sure you're using the right Cloud Name
- Check that your Cloudinary account is active

**3. Large file upload fails**
- Free tier has a 100MB file size limit
- Consider compressing videos before upload
- Upgrade to paid plan for larger files

**4. Video doesn't play**
- Check that the video URL is accessible
- Verify the video format is supported (MP4, MOV, AVI)
- Try opening the URL in a browser

### File Size Limits
- **Free Tier**: 100MB per file
- **Paid Plans**: Up to 10GB per file

### Supported Formats
- **Video**: MP4, MOV, AVI, WebM, FLV
- **Audio**: MP3, WAV, AAC, OGG

## 🔒 Security Best Practices

1. **Never commit credentials to version control**
2. **Use environment variables in production**
3. **Set up proper CORS settings in Cloudinary**
4. **Use signed URLs for sensitive content**
5. **Regularly rotate API keys**

## 📈 Scaling Up

When you need more resources:

1. **Upgrade to Paid Plan**
   - More storage and bandwidth
   - Advanced features
   - Priority support

2. **Optimize Uploads**
   - Compress videos before upload
   - Use appropriate quality settings
   - Implement chunked uploads for large files

3. **Monitor Usage**
   - Check Cloudinary dashboard regularly
   - Monitor bandwidth usage
   - Set up usage alerts

## 🆘 Support

- **Cloudinary Documentation**: https://cloudinary.com/documentation
- **Flutter Package**: https://pub.dev/packages/cloudinary_public
- **Community Forum**: https://support.cloudinary.com

---

**Note**: This setup uses the free tier of Cloudinary. For production use with many users, consider upgrading to a paid plan for better performance and support. 