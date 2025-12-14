import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/user_profile.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../utils/constants/app_colors.dart';
import '../../widgets/avatar_picker.dart';
import '../../widgets/expertise_selector.dart';
import '../../widgets/loading_overlay.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    // Focus areas are loaded by the provider being watched in build()
  }

  @override
  void dispose() {
    _bioController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      await ref.read(profileViewModelProvider.notifier).createProfile(
            _selectedRole!,
            _bioController.text.trim(),
          );
      // Navigation handled by router based on auth/profile state usually, 
      // but explicit push to home might be safer if router doesn't auto-refresh perfectly immediately.
      // However, AppRouter logic will handle redirection.
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final focusAreasAsync = ref.watch(focusAreasProvider);

    // If profile is created successfully, the router (listening to userProfileProvider) should eventually redirect.
    // But local handling:
    ref.listen(profileViewModelProvider, (previous, next) {
      if (next.profile != null && previous?.profile == null) {
         context.go('/home');
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevPage,
              )
            : null,
      ),
      body: LoadingOverlay(
        isLoading: profileState.isLoading,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildRoleSelectionStep(),
                    _buildDetailsStep(profileState, focusAreasAsync),
                    _buildReviewStep(profileState),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicator
                    Row(
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? AppColors.primary
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                         if (_currentPage == 0) {
                           if (_selectedRole == null) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Please select a role')),
                             );
                             return;
                           }
                           _nextPage();
                         } else if (_currentPage == 1) {
                           if (!_formKey.currentState!.validate()) return;
                           _nextPage();
                         } else {
                           _submit();
                         }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                      ),
                      child: Text(
                        _currentPage == 2 ? 'Finish' : 'Next',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Who are you?',
             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildRoleCard(
            role: UserRole.mentor,
            title: "I'm a Mentor",
            icon: Icons.school,
            description: "I want to offer guidance and share my expertise.",
          ),
          const SizedBox(height: 16),
          _buildRoleCard(
            role: UserRole.mentee,
            title: "I'm a Mentee",
            icon: Icons.person_outline,
            description: "I'm looking for guidance and mentorship.",
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required IconData icon,
    required String description,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(20) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
             if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsStep(ProfileState state, AsyncValue focusAreasAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AvatarPicker(
              imageFile: state.avatarFile,
              onImagePicked: (file) =>
                  ref.read(profileViewModelProvider.notifier).setAvatar(file),
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell us a bit about yourself...',
              border: OutlineInputBorder(
                 borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a bio';
              }
              return null;
            },
          ),
          if (_selectedRole == UserRole.mentor) ...[
            const SizedBox(height: 24),
            const Text(
              'Areas of Expertise',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            focusAreasAsync.when(
              data: (focusAreas) => ExpertiseSelector(
                focusAreas: focusAreas,
                selectedAreas: state.selectedExpertise,
                 onSelectionChanged: (area) => ref.read(profileViewModelProvider.notifier).toggleExpertise(area),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading focus areas: $err'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewStep(ProfileState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: AppColors.primary),
           const SizedBox(height: 24),
          const Text(
            'All Set!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
           const SizedBox(height: 8),
          const Text(
            'Please review your profile before finishing.',
            textAlign: TextAlign.center,
             style: TextStyle(color: Colors.grey),
          ),
           const SizedBox(height: 32),
          // Summary card
          Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: Colors.grey[50],
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: Colors.grey[200]!),
             ),
             child: Column(
               children: [
                 if (state.avatarFile != null)
                   CircleAvatar(radius: 40, backgroundImage: FileImage(state.avatarFile!)),
                 const SizedBox(height: 16),
                 Text(
                   _selectedRole == UserRole.mentor ? 'Mentor' : 'Mentee',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                 ),
                 const SizedBox(height: 8),
                 Text(_bioController.text, textAlign: TextAlign.center),
                 if (_selectedRole == UserRole.mentor && state.selectedExpertise.isNotEmpty) ...[
                    const Divider(height: 32),
                    const Text('Expertise', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: state.selectedExpertise
                          .map((e) => Chip(label: Text(e), backgroundColor: Colors.white,))
                          .toList(),
                    )
                 ]
               ],
             ),
          )
        ],
      ),
    );
  }
}
