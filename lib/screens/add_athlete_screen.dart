import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/spacing.dart';
import '../providers/auth_provider.dart';
import '../models/athlete.dart';
import '../services/firebase_service.dart';

class AddAthleteScreen extends StatefulWidget {
  const AddAthleteScreen({super.key});

  @override
  State<AddAthleteScreen> createState() => _AddAthleteScreenState();
}

class _AddAthleteScreenState extends State<AddAthleteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _personalBestController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedGender;
  bool _isSaving = false;
  String _saveStatus = '';

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _personalBestController.dispose();
    _notesController.dispose();
    super.dispose();
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Athlete',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Enter the details of your new athlete to start tracking their progress.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Form
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Card(
                          elevation: 4,
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
                                  _buildInputField(
                                    controller: _fullNameController,
                                    label: 'Full name',
                                    placeholder: 'E.g., Sarah Ade',
                                    validator:
                                        (value) =>
                                            value?.isEmpty == true
                                                ? 'Please enter full name'
                                                : null,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  Row(
                                    children: [
                                      Expanded(child: _buildGenderField()),
                                      const SizedBox(width: AppSpacing.lg),
                                      Expanded(
                                        child: _buildInputField(
                                          controller: _ageController,
                                          label: 'Age',
                                          placeholder: 'Age',
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value?.isEmpty == true)
                                              return 'Please enter age';
                                            if (value == null ||
                                                int.tryParse(value) == null)
                                              return 'Please enter valid age';
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  _buildInputField(
                                    controller: _personalBestController,
                                    label: 'Personal Best',
                                    placeholder: 'E.g., 10.5s',
                                    validator:
                                        (value) =>
                                            value?.isEmpty == true
                                                ? 'Please enter personal best'
                                                : null,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  _buildTextAreaField(),
                                  const SizedBox(height: AppSpacing.xl),

                                  if (_saveStatus.isNotEmpty) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _saveStatus.contains('Error')
                                                ? AppColors.error.withOpacity(
                                                  0.1,
                                                )
                                                : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm,
                                        ),
                                        border: Border.all(
                                          color:
                                              _saveStatus.contains('Error')
                                                  ? AppColors.error
                                                  : Colors.green,
                                        ),
                                      ),
                                      child: Text(
                                        _saveStatus,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color:
                                                  _saveStatus.contains('Error')
                                                      ? AppColors.error
                                                      : Colors.green,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                  ],

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF64748B),
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                        ),
                                        child: TextButton(
                                          onPressed:
                                              _isSaving
                                                  ? null
                                                  : () =>
                                                      Navigator.pop(context),
                                          child: Text(
                                            'Cancel',
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
                                                  color: AppColors.textInverse,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.warning,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                        ),
                                        child: TextButton(
                                          onPressed:
                                              _isSaving ? null : _handleSave,
                                          child:
                                              _isSaving
                                                  ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(
                                                            AppColors
                                                                .textInverse,
                                                          ),
                                                    ),
                                                  )
                                                  : Text(
                                                    'Save Athlete',
                                                    style: AppTextStyles
                                                        .labelLarge
                                                        .copyWith(
                                                          color:
                                                              AppColors
                                                                  .textInverse,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                        ),
                                      ),
                                    ],
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
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
            keyboardType: keyboardType,
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

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
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
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
            hint: Text(
              'Select Gender',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            items:
                _genderOptions
                    .map(
                      (gender) =>
                          DropdownMenuItem(value: gender, child: Text(gender)),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (value) => value == null ? 'Please select gender' : null,
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _saveStatus = 'Saving athlete...';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('User not authenticated. Please log in again.');
      }

      final now = DateTime.now();
      final athlete = Athlete(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _fullNameController.text.trim(),
        gender: _selectedGender!,
        age: int.parse(_ageController.text.trim()),
        personalBest: _personalBestController.text.trim(),
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        coachId: user.uid,
        createdAt: now,
        updatedAt: now,
        videoIds: [],
      );

      print('Creating athlete with data: ${athlete.toMap()}');
      await FirebaseService().addAthlete(athlete);

      setState(() {
        _saveStatus = 'Athlete saved successfully!';
      });

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('Error in _handleSave: $e');
      setState(() {
        _saveStatus = 'Error saving athlete: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
