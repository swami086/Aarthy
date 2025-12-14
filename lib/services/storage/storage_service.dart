import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_service.dart';

class StorageService {
  final SupabaseClient _client = SupabaseService.client;

  Future<String> uploadFile(String bucket, String path, File file) async {
    try {
      await _client.storage.from(bucket).upload(path, file);
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }
}
