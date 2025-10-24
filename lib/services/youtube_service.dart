import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class YouTubeService {
  // YouTube Data API v3 configuration
  static const String _apiKey =
      'YOUR_YOUTUBE_API_KEY'; // Get from Google Cloud Console
  static const String _clientId =
      'YOUR_CLIENT_ID'; // Get from Google Cloud Console
  static const String _clientSecret =
      'YOUR_CLIENT_SECRET'; // Get from Google Cloud Console
  static const String _redirectUri =
      'http://localhost:8080/auth/callback'; // For web

  // YouTube OAuth 2.0 endpoints
  static const String _authUrl = 'https://accounts.google.com/o/oauth2/auth';
  static const String _tokenUrl = 'https://oauth2.googleapis.com/token';
  static const String _uploadUrl =
      'https://www.googleapis.com/upload/youtube/v3/videos';

  /// Upload video to YouTube and return the video URL
  /// This implementation requires proper OAuth 2.0 setup
  Future<String?> uploadVideo({
    required List<int> videoBytes,
    required String fileName,
    required String title,
    required String description,
    List<String> tags = const [],
    String privacyStatus = 'unlisted', // 'public', 'private', 'unlisted'
  }) async {
    try {
      // For web, we'll use a different approach since direct file upload is complex
      if (kIsWeb) {
        return await _uploadVideoWeb(
          videoBytes: videoBytes,
          fileName: fileName,
          title: title,
          description: description,
          tags: tags,
          privacyStatus: privacyStatus,
        );
      } else {
        // For mobile platforms
        return await _uploadVideoMobile(
          videoBytes: videoBytes,
          fileName: fileName,
          title: title,
          description: description,
          tags: tags,
          privacyStatus: privacyStatus,
        );
      }
    } catch (e) {
      throw Exception('Failed to upload video to YouTube: $e');
    }
  }

  /// Upload video for web platform
  Future<String?> _uploadVideoWeb({
    required List<int> videoBytes,
    required String fileName,
    required String title,
    required String description,
    required List<String> tags,
    required String privacyStatus,
  }) async {
    try {
      // For web, we'll provide instructions for manual upload
      // since direct YouTube API upload from web is complex due to CORS and OAuth
      print('Web upload: Providing manual upload instructions');

      // Generate a unique identifier for this upload
      final uploadId = DateTime.now().millisecondsSinceEpoch.toString();

      // Store upload metadata temporarily (in a real app, you'd store this in your database)
      final uploadMetadata = {
        'id': uploadId,
        'title': title,
        'description': description,
        'tags': tags,
        'privacyStatus': privacyStatus,
        'fileName': fileName,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Return instructions for manual upload
      return await getManualUploadInstructions(
        title: title,
        description: description,
        uploadId: uploadId,
      );
    } catch (e) {
      throw Exception('Failed to process web upload: $e');
    }
  }

  /// Upload video for mobile platforms
  Future<String?> _uploadVideoMobile({
    required List<int> videoBytes,
    required String fileName,
    required String title,
    required String description,
    required List<String> tags,
    required String privacyStatus,
  }) async {
    try {
      // Step 1: Get OAuth 2.0 access token
      String? accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception(
          'Failed to get access token. Please authenticate with YouTube.',
        );
      }

      // Step 2: Upload video to YouTube
      final response = await _uploadToYouTube(
        videoBytes: videoBytes,
        fileName: fileName,
        title: title,
        description: description,
        tags: tags,
        privacyStatus: privacyStatus,
        accessToken: accessToken,
      );

      if (response != null) {
        final videoId = response['id'];
        return 'https://www.youtube.com/watch?v=$videoId';
      }

      return null;
    } catch (e) {
      throw Exception('Failed to upload to YouTube: $e');
    }
  }

  /// Get OAuth 2.0 access token
  /// This is a placeholder - you'll need to implement the full OAuth flow
  Future<String?> _getAccessToken() async {
    // TODO: Implement OAuth 2.0 flow
    // 1. Redirect user to Google OAuth consent screen
    // 2. Get authorization code
    // 3. Exchange authorization code for access token
    // 4. Store and refresh tokens as needed

    // For now, return null to indicate this needs to be implemented
    print('OAuth 2.0 not implemented. Please set up YouTube API credentials.');
    return null;
  }

  /// Upload video bytes to YouTube
  Future<Map<String, dynamic>?> _uploadToYouTube({
    required List<int> videoBytes,
    required String fileName,
    required String title,
    required String description,
    required List<String> tags,
    required String privacyStatus,
    required String accessToken,
  }) async {
    try {
      // Prepare the video metadata
      final metadata = {
        'snippet': {
          'title': title,
          'description': description,
          'tags': tags,
          'categoryId': '17', // Sports category
        },
        'status': {'privacyStatus': privacyStatus},
      };

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_uploadUrl?part=snippet,status&uploadType=multipart'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $accessToken';

      // Add video file
      final multipartFile = http.MultipartFile.fromBytes(
        'video',
        videoBytes,
        filename: fileName,
      );
      request.files.add(multipartFile);

      // Add metadata
      request.fields['metadata'] = jsonEncode(metadata);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload to YouTube: $e');
    }
  }

  /// Alternative: Manual upload flow with detailed instructions
  Future<String> getManualUploadInstructions({
    required String title,
    required String description,
    String? uploadId,
  }) async {
    // Return detailed instructions for manual upload
    return '''
Manual Upload Instructions:

1. Go to YouTube Studio (https://studio.youtube.com)
2. Click "CREATE" > "Upload videos"
3. Select your video file
4. Set the following details:
   - Title: $title
   - Description: $description
   - Privacy: Unlisted (recommended for analysis)
   - Category: Sports
   - Tags: sprint, analysis, athletics
5. Click "PUBLISH"
6. Copy the video URL and paste it below

Note: This approach doesn't require API setup and is free to use.
Upload ID: ${uploadId ?? 'N/A'}
    ''';
  }

  /// Validate YouTube URL
  bool isValidYouTubeUrl(String url) {
    final regex = RegExp(
      r'^(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    return regex.hasMatch(url);
  }

  /// Extract video ID from YouTube URL
  String? extractVideoId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  /// Get video thumbnail URL
  String getThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }

  /// Get YouTube API setup instructions
  String getApiSetupInstructions() {
    return '''
YouTube API Setup Instructions:

1. Go to Google Cloud Console (https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable YouTube Data API v3
4. Create OAuth 2.0 credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth 2.0 Client IDs"
   - Set application type to "Web application"
   - Add authorized redirect URIs
5. Download the client configuration
6. Update the constants in YouTubeService:
   - _apiKey
   - _clientId
   - _clientSecret
   - _redirectUri

Note: This requires Google Cloud billing to be enabled.
    ''';
  }
}
