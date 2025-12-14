import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/profile/profile_service.dart';
import '../../models/user_profile.dart';
import '../../models/focus_area.dart';
import 'auth_providers.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final userProfileProvider = FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getProfile(userId);
});

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getProfile(user.id);
});

final focusAreasProvider = FutureProvider<List<FocusArea>>((ref) async {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getFocusAreas();
});
