import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_space_app/models/user_profile.dart';
import '../services/profile/profile_service.dart';
import '../services/auth/auth_service.dart';
import 'providers/profile_providers.dart';
import 'providers/auth_providers.dart';

class ProfileState {
  final bool isLoading;
  final String? errorMessage;
  final UserProfile? profile;
  final File? avatarFile;
  final List<String> selectedExpertise;

  ProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.profile,
    this.avatarFile,
    this.selectedExpertise = const [],
  });

  ProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserProfile? profile,
    File? avatarFile,
    List<String>? selectedExpertise,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      profile: profile ?? this.profile,
      avatarFile: avatarFile ?? this.avatarFile,
      selectedExpertise: selectedExpertise ?? this.selectedExpertise,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  final AuthService _authService;

  ProfileViewModel(this._profileService, this._authService) : super(ProfileState());

  void setAvatar(File file) {
    state = state.copyWith(avatarFile: file);
  }

  void toggleExpertise(String expertise) {
    final current = List<String>.from(state.selectedExpertise);
    if (current.contains(expertise)) {
      current.remove(expertise);
    } else {
      current.add(expertise);
    }
    state = state.copyWith(selectedExpertise: current);
  }

  Future<void> createProfile(UserRole role, String bio) async {
    final user = _authService.currentUser;
    if (user == null) {
      state = state.copyWith(errorMessage: "No authenticated user found");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      String? avatarUrl;
      if (state.avatarFile != null) {
        avatarUrl = await _profileService.uploadAvatar(state.avatarFile!, user.id);
      }

      final newProfile = UserProfile(
        userId: user.id,
        role: role,
        bio: bio,
        avatarUrl: avatarUrl,
        expertiseAreas: role == UserRole.mentor ? state.selectedExpertise : [],
      );

      await _profileService.createProfile(newProfile);
      state = state.copyWith(profile: newProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateProfile(String bio) async {
    if (state.profile == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
       String? avatarUrl = state.profile?.avatarUrl;
       if (state.avatarFile != null) {
        avatarUrl = await _profileService.replaceAvatar(
          state.avatarFile!, 
          state.profile!.userId, 
          oldAvatarUrl: state.profile?.avatarUrl
        );
      }

      final updatedProfile = state.profile!.copyWith(
        bio: bio,
        avatarUrl: avatarUrl,
        expertiseAreas: state.profile!.role == UserRole.mentor ? state.selectedExpertise : [],
        updatedAt: DateTime.now(),
      );

      await _profileService.updateProfile(updatedProfile);
      state = state.copyWith(profile: updatedProfile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
  
  void initProfile(UserProfile profile) {
    state = state.copyWith(
      profile: profile,
      selectedExpertise: profile.expertiseAreas,
    );
  }
}

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(
    ref.watch(profileServiceProvider),
    ref.watch(authServiceProvider),
  );
});
