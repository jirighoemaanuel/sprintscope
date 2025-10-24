import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/spacing.dart';
import '../providers/auth_provider.dart';
import '../models/video.dart';
import '../models/athlete.dart';
import '../services/firebase_service.dart';
import '../services/youtube_service.dart';
import '../services/video_upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();
  final _youtubeUrlController = TextEditingController();

  String? _selectedAthleteId;
  String? _selectedVideoPath;
  List<int>? _selectedVideoBytes; // Store the actual file bytes
  bool _isUploading = false;
  String _uploadStatus = '';
  bool _useManualUrl = false;
  List<Athlete> _athletes = [];
  bool _isLoadingAthletes = true;
  DateTime? _selectedDate;

  final YouTubeService _youtubeService = YouTubeService();
  final VideoUploadService _videoUploadService = VideoUploadService();

  @override
  void initState() {
    super.initState();
    _loadAthletes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadAthletes() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        final athletes = await FirebaseService().getUserAthletes(user.uid);
        setState(() {
          _athletes = athletes;
          _isLoadingAthletes = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingAthletes = false;
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
                // Header/Navigation Bar
                Container(
                  color: const Color(0xFF1E293B),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? AppSpacing.sm : AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      // Logo
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
                      // Navigation Links (hidden on mobile)
                      if (!isMobile) ...[
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/dashboard',
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
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
                          onPressed: () {
                            // TODO: Navigate to settings
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                          ),
                          child: Text(
                            'Settings',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      // Coach Name/Profile Button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/coach-profile');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
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
                      // Mobile menu button
                      if (isMobile) ...[
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: AppColors.textInverse,
                            size: 20,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Main Content Area
                Container(
                  color: const Color(0xFFF8FAFC),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      Text(
                        'Upload New Sprint Video',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Upload a video of your athlete\'s sprint for detailed analysis',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Upload Method Toggle
                      _buildUploadMethodToggle(),
                      const SizedBox(height: AppSpacing.lg),

                      // Upload Form
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Card(
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Video Upload Area
                                  _buildVideoUploadArea(),
                                  const SizedBox(height: AppSpacing.xl),

                                  // Video Metadata Fields
                                  _buildMetadataFields(),
                                  const SizedBox(height: AppSpacing.xl),

                                  // Upload Status
                                  if (_uploadStatus.isNotEmpty) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _uploadStatus.contains('Error')
                                                ? AppColors.error.withOpacity(
                                                  0.1,
                                                )
                                                : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm,
                                        ),
                                        border: Border.all(
                                          color:
                                              _uploadStatus.contains('Error')
                                                  ? AppColors.error
                                                  : Colors.green,
                                        ),
                                      ),
                                      child: Text(
                                        _uploadStatus,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color:
                                                  _uploadStatus.contains(
                                                        'Error',
                                                      )
                                                      ? AppColors.error
                                                      : Colors.green,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                  ],

                                  // Submit Button
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.warning,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMd,
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed:
                                          _isUploading ? null : _handleSubmit,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.lg,
                                          vertical: AppSpacing.md,
                                        ),
                                      ),
                                      child:
                                          _isUploading
                                              ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppColors.textInverse),
                                                ),
                                              )
                                              : Text(
                                                'Save and continue to analysis',
                                                style: AppTextStyles.labelLarge
                                                    .copyWith(
                                                      color:
                                                          AppColors.textInverse,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _buildUploadMethodToggle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Method',
            style: AppTextStyles.labelLarge.copyWith(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _useManualUrl = false),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color:
                          !_useManualUrl
                              ? AppColors.warning.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color:
                            !_useManualUrl
                                ? AppColors.warning
                                : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.upload_file,
                          color:
                              !_useManualUrl
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload File',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      !_useManualUrl
                                          ? AppColors.warning
                                          : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Upload video file directly',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _useManualUrl = true),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color:
                          _useManualUrl
                              ? AppColors.warning.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color:
                            _useManualUrl
                                ? AppColors.warning
                                : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          color:
                              _useManualUrl
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cloudinary URL',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _useManualUrl
                                          ? AppColors.warning
                                          : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Paste Cloudinary video URL',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoUploadArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _useManualUrl ? 'Cloudinary Video URL' : 'Video File',
          style: AppTextStyles.labelLarge.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        if (_useManualUrl) ...[
          // Cloudinary URL Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextFormField(
              controller: _youtubeUrlController,
              decoration: InputDecoration(
                hintText:
                    'https://res.cloudinary.com/your-cloud/video/upload/...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: _showManualUploadInstructions,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a Cloudinary URL';
                }
                if (!value.contains('cloudinary.com')) {
                  return 'Please enter a valid Cloudinary URL';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Paste the Cloudinary URL of your uploaded video',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ] else ...[
          // File Upload Area
          GestureDetector(
            onTap: _pickVideoFile,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color:
                      _selectedVideoPath != null
                          ? AppColors.warning
                          : const Color(0xFFCBD5E1),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child:
                  _selectedVideoPath != null
                      ? _buildSelectedVideoDisplay()
                      : _buildUploadPrompt(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Supports MP4, MOV, AVI up to 500MB',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.folder_open, size: 48, color: AppColors.warning),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Drag & Drop Video File Here',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Or click to browse your files',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedVideoDisplay() {
    final selectedVideoPath = _selectedVideoPath;
    if (selectedVideoPath == null) {
      return const SizedBox.shrink();
    }

    final fileName =
        selectedVideoPath.contains('/')
            ? selectedVideoPath.split('/').last
            : selectedVideoPath;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_file, size: 48, color: AppColors.warning),
          const SizedBox(height: AppSpacing.sm),
          Text(
            fileName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _pickVideoFile,
            child: Text(
              'Change File',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Title
        _buildInputField(
          controller: _titleController,
          label: 'Video Title',
          placeholder: 'E.g., Sarah Ade - Final 100m',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a video title';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Select Athlete
        _buildDropdownField(),
        const SizedBox(height: AppSpacing.lg),

        // Video Date
        _buildDatePickerField(),
        const SizedBox(height: AppSpacing.lg),

        // Notes
        _buildTextAreaField(),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    String? Function(String?)? validator,
  }) {
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Date',
          style: AppTextStyles.labelLarge.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null && pickedDate != _selectedDate) {
                setState(() {
                  _selectedDate = pickedDate;
                  _dateController.text =
                      '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}';
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Select date',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please select a video date';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Athlete',
          style: AppTextStyles.labelLarge.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child:
              _isLoadingAthletes
                  ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : _athletes.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No athletes found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-athlete');
                          },
                          child: Text(
                            'Add your first athlete',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : DropdownButtonFormField<String>(
                    value: _selectedAthleteId,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                    ),
                    hint: Text(
                      'Select an athlete',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    items:
                        _athletes.map((athlete) {
                          return DropdownMenuItem(
                            value: athlete.id,
                            child: Text(athlete.fullName),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAthleteId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an athlete';
                      }
                      return null;
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: AppTextStyles.labelLarge.copyWith(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Any additional notes...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickVideoFile() async {
    try {
      print('Starting file picker...');
      print('Platform: ${kIsWeb ? 'Web' : 'Mobile'}');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['mp4', 'mov', 'avi'],
      );

      print(
        'File picker result: ${result != null ? 'File selected' : 'No file selected'}',
      );

      if (result != null) {
        final file = result.files.single;
        print('Selected file: ${file.name}');
        print('File size: ${file.size} bytes');
        print(
          'File bytes: ${file.bytes != null ? 'Available' : 'Not available'}',
        );

        // Check file size (500MB limit)
        if (file.size > 500 * 1024 * 1024) {
          print('File too large: ${file.size} bytes');
          setState(() {
            _uploadStatus = 'Error: File size must be less than 500MB';
          });
          return;
        }

        setState(() {
          // Always use file name for consistency across platforms
          print('Using file name: ${file.name}');
          _selectedVideoPath = file.name;
          _selectedVideoBytes = file.bytes; // Store the bytes
          _uploadStatus = ''; // Clear any previous errors
        });
        print('File selection completed successfully');
      }
    } catch (e, stackTrace) {
      print('Error in _pickVideoFile: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _uploadStatus = 'Error selecting file: $e';
      });
    }
  }

  void _showManualUploadInstructions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cloudinary Setup Instructions'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'To set up automatic video uploads:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '1. Go to Cloudinary (https://cloudinary.com) and sign up for free\n'
                    '2. Get your credentials from the Dashboard:\n'
                    '   - Cloud Name\n'
                    '   - API Key\n'
                    '   - API Secret\n'
                    '3. Update the constants in VideoUploadService\n'
                    '4. Restart the app\n'
                    '5. Videos will be automatically uploaded to Cloudinary',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Free tier includes 25GB storage and 25GB bandwidth per month.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_useManualUrl && _selectedVideoPath == null) {
      setState(() {
        _uploadStatus = 'Please select a video file';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus =
          _useManualUrl
              ? 'Saving video metadata...'
              : 'Processing video file...';
    });

    try {
      String videoUrl;

      if (_useManualUrl) {
        // Use provided Cloudinary URL
        videoUrl = _youtubeUrlController.text.trim();
      } else {
        // For web, we need to get the file bytes from the file picker result
        // Since we don't have the file bytes stored, we'll show instructions
        if (kIsWeb) {
          // Check if we have the video bytes
          if (_selectedVideoBytes == null) {
            setState(() {
              _uploadStatus = 'Please select your video file again';
            });
            return;
          }

          // Automatic upload to Cloudinary
          try {
            final uploadedUrl = await _videoUploadService.uploadVideo(
              videoBytes: _selectedVideoBytes!,
              fileName: _selectedVideoPath!,
              title: _titleController.text.trim(),
            );

            if (uploadedUrl != null) {
              videoUrl = uploadedUrl;
              setState(() {
                _uploadStatus = 'Video uploaded successfully! URL: $videoUrl';
              });
            } else {
              throw Exception('Upload failed - no URL returned');
            }
          } catch (e) {
            setState(() {
              _uploadStatus = 'Upload failed: $e. Please try manual upload.';
            });
            return;
          }
        } else {
          // For mobile, we can try automatic upload
          // This would require storing the file bytes when selected
          throw Exception(
            'Automatic upload requires file bytes. Please use manual upload for now.',
          );
        }
      }

      setState(() {
        _uploadStatus = 'Video uploaded successfully! Saving to database...';
      });

      // Save video metadata to Firebase
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        final selectedAthlete = _athletes.firstWhere(
          (a) => a.id == _selectedAthleteId,
        );

        final selectedDate = _selectedDate;
        final video = Video(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          athleteName: selectedAthlete.fullName,
          athleteId: selectedAthlete.id,
          event: '100m Sprint',
          uploadDate:
              selectedDate != null
                  ? '${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year.toString().substring(2)}'
                  : _dateController.text.trim(),
          videoUrl: videoUrl,
          thumbnailUrl:
              videoUrl.contains('cloudinary.com')
                  ? videoUrl.replaceAll(
                    '/upload/',
                    '/upload/w_300,h_200,c_fill/',
                  )
                  : null,
          coachId: user.uid,
        );

        await FirebaseService().addVideo(video);

        setState(() {
          _uploadStatus =
              'Video saved successfully! Redirecting to analysis...';
        });

        // Navigate to video analysis after successful upload
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/video-analysis',
            arguments: {'video': video},
          );
        }
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error uploading video: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
