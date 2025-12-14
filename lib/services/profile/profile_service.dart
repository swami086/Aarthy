import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart';
import '../../models/focus_area.dart';
import '../supabase/supabase_service.dart';
import '../storage/storage_service.dart';

class ProfileService {
  final SupabaseClient _client = SupabaseService.client;
  final StorageService _storageService = StorageService();

  Future<void> createProfile(UserProfile profile) async {
    try {
      await _client.from('profiles').insert(profile.toJson());
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _client
          .from('profiles')
          .update(profile.toJson())
          .eq('user_id', profile.userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<String> uploadAvatar(File imageFile, String userId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${userId}_$timestamp.jpg';
    return await _storageService.uploadFile('avatars', path, imageFile);
  }

  Future<void> deleteAvatar(String path) async {
    // Extract file path from public URL if necessary, but here path is assumed to be storage path or we parse it.
    // For now assuming we just pass the relative storage path or handle full URL parsing.
    // Supabase storage paths are usually just the filename if at root of bucket.
    // If we only store the public URL, we need to extract the path.
    // Assuming we store public URL, let's try to extract the last segment.
    
    try {
      final uri = Uri.parse(path);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        // e.g. /storage/v1/object/public/avatars/userId_timestamp.jpg
        // The actual path in bucket is usually the last part if not in folders.
        // But getPublicUrl logic depends on bucket config.
        // Let's assume the file name is at the end.
        final fileName = segments.last; 
        await _storageService.deleteFile('avatars', fileName);
      }
    } catch (e) {
      // If parsing fails or not a URL, try deleting as raw path
      // await _storageService.deleteFile('avatars', path);
      // Suppress delete errors to avoid blocking update flow
      print('Error deleting old avatar: $e');
    }
  }

  Future<String> replaceAvatar(File newImage, String userId, {String? oldAvatarUrl}) async {
    if (oldAvatarUrl != null) {
      await deleteAvatar(oldAvatarUrl);
    }
    return await uploadAvatar(newImage, userId);
  }

  Future<List<FocusArea>> getFocusAreas() async {
    try {
      final response = await _client.from('focus_areas').select();
      return (response as List).map((e) => FocusArea.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch focus areas: $e');
    }
  }
}
