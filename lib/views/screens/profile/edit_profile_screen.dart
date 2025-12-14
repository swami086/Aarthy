import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_space_app/models/user_profile.dart';
import 'package:safe_space_app/viewmodels/viewmodels.dart';
import '../../widgets/avatar_picker.dart';
import '../../widgets/expertise_selector.dart';
import '../../widgets/loading_overlay.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(profileViewModelProvider.notifier)
          .updateProfile(_bioController.text.trim());
      if (mounted && ref.read(profileViewModelProvider).errorMessage == null) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final currentUserProfile = ref.watch(currentUserProfileProvider);
    final focusAreasAsync = ref.watch(focusAreasProvider);

    // Initialize form with current profile data once loaded
    if (!_initialized && currentUserProfile.hasValue && currentUserProfile.value != null) {
      final profile = currentUserProfile.value!;
      _bioController.text = profile.bio ?? '';
      
      // We need to defer this update to avoid modifying provider during build
      // Using Future.microtask or just relying on init logic if VM supports it.
      // Better to call initProfile method on the notifier.
      WidgetsBinding.instance.addPostFrameCallback((_) {
         ref.read(profileViewModelProvider.notifier).initProfile(profile);
      });
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submit,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: profileState.isLoading,
        child: currentUserProfile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (profile) {
            if (profile == null) return const Center(child: Text('Profile not found'));
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: AvatarPicker(
                        imageFile: profileState.avatarFile,
                        imageUrl: profile.avatarUrl,
                        onImagePicked: (file) =>
                            ref.read(profileViewModelProvider.notifier).setAvatar(file),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
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
                    if (profile.role == UserRole.mentor) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Areas of Expertise',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      focusAreasAsync.when(
                        data: (focusAreas) => ExpertiseSelector(
                          focusAreas: focusAreas,
                          selectedAreas: profileState.selectedExpertise,
                          onSelectionChanged: (area) =>
                              ref.read(profileViewModelProvider.notifier).toggleExpertise(area),
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                         error: (err, stack) => Text('Error loading focus areas: $err'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
