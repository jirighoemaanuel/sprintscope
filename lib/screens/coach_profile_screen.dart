import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/spacing.dart';
import '../providers/auth_provider.dart';
import '../models/athlete.dart';
import '../models/video.dart';
import '../services/firebase_service.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  bool _isLoading = true;
  String _coachName = '';
  String _coachEmail = '';
  String _coachFullName = '';
  int _athleteCount = 0;
  int _videoCount = 0;
  int _monthlyCount = 0;
  DateTime? _joinDate;

  @override
  void initState() {
    super.initState();
    _loadCoachData();
  }

  Future<void> _loadCoachData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        // Load coach profile data
        final userData = await FirebaseService().getUserData(user.uid);

        // Load athletes count
        final athletes = await FirebaseService().getUserAthletes(user.uid);

        // Load videos count
        final videos = await FirebaseService().getUserVideos(user.uid);

        // Calculate monthly videos (videos from current month)
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final monthlyVideos =
            videos.where((video) {
              final videoDate = DateTime.tryParse(video.uploadDate);
              return videoDate != null && videoDate.isAfter(startOfMonth);
            }).length;

        setState(() {
          _coachName = userData['fullName']?.split(' ').last ?? 'Coach';
          _coachEmail = user.email ?? '';
          _coachFullName = userData['fullName'] ?? '';
          _athleteCount = athletes.length;
          _videoCount = videos.length;
          _monthlyCount = monthlyVideos;
          _joinDate =
              userData['createdAt'] != null
                  ? (userData['createdAt'] as Timestamp).toDate()
                  : DateTime.now();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading coach data: $e');
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
                            'Video Upload',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Settings',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
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
                              // Coach Summary Section
                              Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getInitials(_coachFullName),
                                        style: AppTextStyles.headlineMedium
                                            .copyWith(
                                              color: AppColors.textInverse,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  // Coach Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _coachFullName,
                                          style: AppTextStyles.headlineLarge
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF1E293B),
                                              ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          'Head Sprint Coach · Joined ${_getJoinDateText()}',
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

                              // KPI Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildKPICard(
                                      '$_athleteCount',
                                      'Athletes',
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: _buildKPICard(
                                      '$_videoCount',
                                      'videos analyzed',
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: _buildKPICard(
                                      '$_monthlyCount',
                                      'This month',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Coach Profile Details
                              Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  maxWidth: 600,
                                ),
                                child: Card(
                                  elevation: 4,
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusLg,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.xl,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Coach Profile',
                                          style: AppTextStyles.headlineMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1E293B),
                                              ),
                                        ),
                                        const SizedBox(height: AppSpacing.lg),

                                        // Full Name Field
                                        _buildProfileField(
                                          'FullName',
                                          _coachFullName,
                                        ),
                                        const SizedBox(height: AppSpacing.lg),

                                        // Email Field
                                        _buildProfileField(
                                          'Email',
                                          _coachEmail,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

  Widget _buildKPICard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(left: BorderSide(color: AppColors.warning, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF1E293B),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'CS';
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }

  String _getJoinDateText() {
    final joinDate = _joinDate;
    if (joinDate == null) return 'January 2025';

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final month = months[joinDate.month - 1];
    final year = joinDate.year;

    return '$month $year';
  }
}
