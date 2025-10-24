import 'dart:convert';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/foundation.dart';

class VideoUploadService {
  // Cloudinary configuration
  static const String _cloudName = 'det27ryaj';
  static const String _apiKey = '192752416811838';
  static const String _apiSecret = '2Xc_zEx-2ejQu5H3M15TDsXGlsg';

  // Cloudinary instance
  late final Cloudinary _cloudinary;

  VideoUploadService() {
    _cloudinary = Cloudinary.signedConfig(
      apiKey: _apiKey,
      apiSecret: _apiSecret,
      cloudName: _cloudName,
    );
  }

  /// Upload video to Cloudinary and return the video URL
  Future<String?> uploadVideo({
    required List<int> videoBytes,
    required String fileName,
    String? title,
  }) async {
    try {
      print('Uploading video to Cloudinary: $fileName');
      print('Video size: ${videoBytes.length} bytes');

      // Generate unique public ID
      final publicId = _generatePublicId(fileName);

      // Upload to Cloudinary using the official package
      final response = await _cloudinary.upload(
        fileBytes: videoBytes,
        resourceType: CloudinaryResourceType.video,
        folder: 'sprintscope_videos',
        publicId: publicId,
      );

      if (response.isSuccessful) {
        final videoUrl = response.secureUrl;
        print('Video uploaded successfully to Cloudinary: $videoUrl');
        return videoUrl;
      } else {
        print('Cloudinary upload failed: ${response.error}');
        throw Exception('Upload failed: ${response.error}');
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      throw Exception('Failed to upload video to Cloudinary: $e');
    }
  }

  /// Generate a unique public ID for the video
  String _generatePublicId(String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'sprint_${cleanFileName}_$timestamp';
  }

  /// Get Cloudinary upload instructions
  String getUploadInstructions() {
    return '''
Cloudinary Upload Instructions:

1. Sign up for a free Cloudinary account at https://cloudinary.com
2. Get your credentials from the Dashboard:
   - Cloud Name
   - API Key
   - API Secret
3. Update the constants in VideoUploadService:
   - _cloudName
   - _apiKey
   - _apiSecret
4. Your videos will be automatically uploaded to Cloudinary

Note: Free tier includes 25GB storage and 25GB bandwidth per month.
    ''';
  }

  /// Check if Cloudinary is configured
  bool isCloudinaryConfigured() {
    return _cloudName != 'YOUR_CLOUDINARY_CLOUD_NAME' &&
        _apiKey != 'YOUR_CLOUDINARY_API_KEY' &&
        _apiSecret != 'YOUR_CLOUDINARY_API_SECRET';
  }

  /// Get Cloudinary setup instructions
  String getCloudinarySetupInstructions() {
    return '''
Cloudinary Setup Instructions:

1. Go to Cloudinary (https://cloudinary.com) and sign up for free
2. After signing up, go to your Dashboard
3. Copy your credentials:
   - Cloud Name (found in the URL: https://cloudinary.com/console)
   - API Key (from Dashboard > Settings > Access Keys)
   - API Secret (from Dashboard > Settings > Access Keys)
4. Update the constants in VideoUploadService:
   - Replace _cloudName with your cloud name
   - Replace _apiKey with your API key
   - Replace _apiSecret with your API secret
5. Restart the app

Free Tier Benefits:
- 25GB storage
- 25GB bandwidth per month
- Automatic video optimization
- CDN delivery
- No credit card required
    ''';
  }

  /// Get video URL from Cloudinary public ID
  String getVideoUrl(String publicId) {
    return 'https://res.cloudinary.com/$_cloudName/video/upload/$publicId';
  }

  /// Get video thumbnail URL
  String getThumbnailUrl(String publicId) {
    return 'https://res.cloudinary.com/$_cloudName/video/upload/w_300,h_200,c_fill/$publicId';
  }
}
