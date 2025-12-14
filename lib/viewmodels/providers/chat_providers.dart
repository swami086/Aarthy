import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_space_app/services/chat/chat_service.dart';
import 'package:safe_space_app/models/message.dart';
import 'package:safe_space_app/models/conversation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Service Provider
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(Supabase.instance.client);
});

// Conversations List Provider
final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final service = ref.watch(chatServiceProvider);
  return service.getConversations();
});

// Conversation Messages Stream Provider (Family)
final conversationMessagesProvider = StreamProvider.family.autoDispose<List<Message>, String>((ref, otherUserId) {
  final service = ref.watch(chatServiceProvider);
  return service.getConversationMessagesStream(otherUserId);
});

// Unread Count Stream Provider
final unreadCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(chatServiceProvider);
  return service.getUnreadCountStream();
});
