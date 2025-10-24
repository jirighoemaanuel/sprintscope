import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/spacing.dart';
import '../models/video.dart';
import '../models/athlete.dart';
import '../services/firebase_service.dart';
import '../services/youtube_service.dart';

class VideoAnalysisScreen extends StatefulWidget {
  final Video video;

  const VideoAnalysisScreen({super.key, required this.video});

  @override
  State<VideoAnalysisScreen> createState() => _VideoAnalysisScreenState();
}

class _VideoAnalysisScreenState extends State<VideoAnalysisScreen> {
  bool _isLoading = true;
  Athlete? _athlete;
  Map<String, dynamic> _analysisData = {};
  List<Map<String, dynamic>> _performanceMetrics = [];
  List<Map<String, dynamic>> _recommendations = [];

  // Video player controller
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isFullscreen = false;

  Timer? _hideControlsTimer;
  final Duration _controlsHideDelay = const Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.video.videoUrl != null && widget.video.videoUrl!.isNotEmpty) {
      try {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.video.videoUrl!),
        );

        await _videoController!.initialize();

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      } catch (e) {
        print('Error initializing video player: $e');
      }
    }
  }

  Future<void> _loadAnalysisData() async {
    try {
      // Load athlete data
      if (widget.video.athleteId.isNotEmpty) {
        _athlete = await FirebaseService().getAthleteById(
          widget.video.athleteId,
        );
      }

      // Simulate analysis data (in real app, this would come from your analysis API)
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _analysisData = {
          'overallScore': 8.2,
          'speedScore': 8.5,
          'techniqueScore': 7.8,
          'formScore': 8.1,
          'totalTime': '10.45s',
          'reactionTime': '0.18s',
          'acceleration': '2.8 m/s²',
          'maxSpeed': '11.2 m/s',
          'strideLength': '2.1m',
          'strideFrequency': '4.8 strides/s',
        };

        _performanceMetrics = [
          {
            'metric': 'Reaction Time',
            'value': '0.18s',
            'status': 'excellent',
            'description': 'Quick start reaction time',
            'icon': Icons.flash_on,
          },
          {
            'metric': 'Acceleration',
            'value': '2.8 m/s²',
            'status': 'good',
            'description': 'Strong initial acceleration',
            'icon': Icons.trending_up,
          },
          {
            'metric': 'Max Speed',
            'value': '11.2 m/s',
            'status': 'excellent',
            'description': 'High top-end speed achieved',
            'icon': Icons.speed,
          },
          {
            'metric': 'Stride Length',
            'value': '2.1m',
            'status': 'good',
            'description': 'Optimal stride length maintained',
            'icon': Icons.straighten,
          },
          {
            'metric': 'Stride Frequency',
            'value': '4.8 strides/s',
            'status': 'needs_improvement',
            'description': 'Could increase stride frequency',
            'icon': Icons.repeat,
          },
        ];

        _recommendations = [
          {
            'title': 'Improve Stride Frequency',
            'description':
                'Focus on increasing leg turnover rate during acceleration phase',
            'priority': 'high',
            'icon': Icons.trending_up,
          },
          {
            'title': 'Maintain Drive Phase',
            'description':
                'Keep driving forward for longer before transitioning to upright running',
            'priority': 'medium',
            'icon': Icons.directions_run,
          },
          {
            'title': 'Arm Action',
            'description':
                'Ensure arms are driving forward and back, not across the body',
            'priority': 'low',
            'icon': Icons.accessibility,
          },
        ];

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analysis data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  color: const Color(0xFF1E293B),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? AppSpacing.sm : AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Sprint',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textInverse,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: 'Scope',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (!isMobile) ...[
                        TextButton(
                          onPressed:
                              () => Navigator.pushReplacementNamed(
                                context,
                                '/dashboard',
                              ),
                          child: Text(
                            'Dashboard',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        TextButton(
                          onPressed:
                              () => Navigator.pushNamed(context, '/upload'),
                          child: Text(
                            'Upload Video',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: TextButton(
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                '/coach-profile',
                              ),
                          child: Text(
                            'Coach Smith',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textInverse,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Container(
                  color: const Color(0xFFF8FAFC),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Section
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sprint Analysis',
                                          style: AppTextStyles.headlineLarge
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF1E293B),
                                              ),
                                        ),
                                        Text(
                                          '${widget.video.title} • ${_athlete?.fullName ?? widget.video.athleteName}',
                                          style: AppTextStyles.bodyLarge
                                              .copyWith(
                                                color: const Color(0xFF64748B),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Overall Score Card
                              _buildOverallScoreCard(),
                              const SizedBox(height: AppSpacing.lg),

                              // Video Player Section
                              _buildVideoPlayer(),
                              const SizedBox(height: AppSpacing.xl),

                              // Performance Metrics Grid
                              Text(
                                'Performance Metrics',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildMetricsGrid(isMobile),
                              const SizedBox(height: AppSpacing.xl),

                              // Recommendations
                              Text(
                                'Recommendations',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _buildRecommendationsList(),
                              const SizedBox(height: AppSpacing.xl),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF64748B),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusMd,
                                        ),
                                      ),
                                      child: TextButton(
                                        onPressed:
                                            () =>
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  '/dashboard',
                                                ),
                                        child: Text(
                                          'Back to Dashboard',
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                                color: AppColors.textInverse,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.warning,
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusMd,
                                        ),
                                      ),
                                      child: TextButton(
                                        onPressed:
                                            () => Navigator.pushNamed(
                                              context,
                                              '/upload',
                                            ),
                                        child: Text(
                                          'Upload Another Video',
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                                color: AppColors.textInverse,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Performance Score',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Based on speed, technique, and form analysis',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getScoreColor(_analysisData['overallScore'] ?? 0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${_analysisData['overallScore']?.toStringAsFixed(1) ?? '0.0'}',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildScoreItem(
                  'Speed',
                  _analysisData['speedScore'] ?? 0,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildScoreItem(
                  'Technique',
                  _analysisData['techniqueScore'] ?? 0,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildScoreItem('Form', _analysisData['formScore'] ?? 0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, double score) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          score.toStringAsFixed(1),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    final videoUrl = widget.video.videoUrl;

    if (videoUrl == null || videoUrl.isEmpty) {
      return _buildNoVideoFallback('No video URL provided');
    }

    if (videoUrl.contains('cloudinary.com')) {
      // Show Cloudinary video with actual video player
      return Container(
        width: double.infinity,
        height: _isFullscreen ? MediaQuery.of(context).size.height : 300,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius:
              _isFullscreen
                  ? BorderRadius.zero
                  : BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: ClipRRect(
          borderRadius:
              _isFullscreen
                  ? BorderRadius.zero
                  : BorderRadius.circular(AppSpacing.radiusMd),
          child:
              _isVideoInitialized
                  ? Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video player
                      AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                      // Play/Pause button overlay
                      if (!_isPlaying && _showControls)
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      // Video controls overlay
                      if (_showControls)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Progress bar
                                VideoProgressIndicator(
                                  _videoController!,
                                  allowScrubbing: true,
                                  colors: const VideoProgressColors(
                                    playedColor: AppColors.warning,
                                    bufferedColor: Colors.grey,
                                    backgroundColor: Colors.white24,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                // Control buttons
                                Row(
                                  children: [
                                    // Play/Pause button
                                    GestureDetector(
                                      onTap: _togglePlayPause,
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        child: Icon(
                                          _isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    // Rewind button
                                    GestureDetector(
                                      onTap: () {
                                        final currentPosition =
                                            _videoController!.value.position;
                                        final newPosition =
                                            currentPosition -
                                            const Duration(seconds: 10);
                                        _videoController!.seekTo(newPosition);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        child: const Icon(
                                          Icons.replay_10,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    // Fast forward button
                                    GestureDetector(
                                      onTap: () {
                                        final currentPosition =
                                            _videoController!.value.position;
                                        final newPosition =
                                            currentPosition +
                                            const Duration(seconds: 10);
                                        _videoController!.seekTo(newPosition);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        child: const Icon(
                                          Icons.forward_10,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    // Video duration
                                    Expanded(
                                      child: ValueListenableBuilder(
                                        valueListenable: _videoController!,
                                        builder: (
                                          context,
                                          VideoPlayerValue value,
                                          child,
                                        ) {
                                          return Text(
                                            '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(color: Colors.white),
                                          );
                                        },
                                      ),
                                    ),
                                    // Volume control
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (_videoController!.value.volume >
                                              0) {
                                            _videoController!.setVolume(0);
                                          } else {
                                            _videoController!.setVolume(1);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        child: ValueListenableBuilder(
                                          valueListenable: _videoController!,
                                          builder: (
                                            context,
                                            VideoPlayerValue value,
                                            child,
                                          ) {
                                            return Icon(
                                              value.volume > 0
                                                  ? Icons.volume_up
                                                  : Icons.volume_off,
                                              color: Colors.white,
                                              size: 24,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    // Fullscreen button
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isFullscreen = !_isFullscreen;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        child: Icon(
                                          _isFullscreen
                                              ? Icons.fullscreen_exit
                                              : Icons.fullscreen,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Video title overlay
                      if (_showControls)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.video.title,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Close fullscreen button
                                if (_isFullscreen)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isFullscreen = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.sm,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      // Tap to show/hide controls (only when controls are hidden)
                      if (!_showControls)
                        GestureDetector(
                          onTap: _showControlsTemporarily,
                          child: Container(
                            color: Colors.transparent,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                    ],
                  )
                  : _buildVideoLoadingState(),
        ),
      );
    } else {
      // Fallback for non-Cloudinary URLs or invalid URLs
      return _buildNoVideoFallback('Invalid Cloudinary URL: $videoUrl');
    }
  }

  Widget _buildVideoLoadingState() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
            ),
            SizedBox(height: AppSpacing.sm),
            Text('Loading video...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildNoVideoFallback(String message) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 48, color: Colors.grey[600]),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Video Not Available',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.5,
      ),
      itemCount: _performanceMetrics.length,
      itemBuilder: (context, index) {
        final metric = _performanceMetrics[index];
        return _buildMetricCard(metric);
      },
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: _getStatusColor(metric['status']), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _getStatusColor(metric['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              metric['icon'],
              color: _getStatusColor(metric['status']),
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric['metric'],
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  metric['value'],
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(metric['status']),
                  ),
                ),
                Text(
                  metric['description'],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList() {
    return Column(
      children:
          _recommendations.map((recommendation) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: _getPriorityColor(recommendation['priority']),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                        recommendation['priority'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      recommendation['icon'],
                      color: _getPriorityColor(recommendation['priority']),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              recommendation['title'],
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(
                                  recommendation['priority'],
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm,
                                ),
                              ),
                              child: Text(
                                recommendation['priority'].toUpperCase(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          recommendation['description'],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 6.0) return Colors.orange;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'needs_improvement':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });

    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(_controlsHideDelay, () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
      } else {
        _videoController!.play();
        _isPlaying = true;
      }
    });
    _showControlsTemporarily();
  }
}
