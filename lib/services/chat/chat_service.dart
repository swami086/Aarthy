import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/message.dart';
import '../../models/conversation.dart';
import '../../models/user_profile.dart';
import '../storage/storage_service.dart';

class ChatService {
  final SupabaseClient _client;
  final StorageService _storageService;

  ChatService(this._client, [StorageService? storageService]) 
    : _storageService = storageService ?? StorageService();

  /// Get real-time stream of messages for a specific conversation
  Stream<List<Message>> getConversationMessagesStream(String otherUserId) {
    final currentUserId = _client.auth.currentUser!.id;
    
    // Note: Supabase stream API doesn't support .or() - using client-side filter
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) {
          final messages = data.map((json) => Message.fromJson(json)).toList();
          return messages.where((m) => 
            (m.senderId == currentUserId && m.receiverId == otherUserId) ||
            (m.senderId == otherUserId && m.receiverId == currentUserId)
          ).toList();
        });
  }

  /// Send a text message
  Future<Message> sendMessage(String receiverId, String content, {String? attachmentUrl, String? attachmentType}) async {
    final currentUserId = _client.auth.currentUser!.id;
    
    try {
      final response = await _client.from('messages').insert({
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        'content': content,
        'is_read': false,
        'attachment_url': attachmentUrl,
        'attachment_type': attachmentType,
      }).select().single();

      return Message.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Upload attachment to storage
  Future<String> uploadAttachment(File file, String messageId) async {
    final currentUserId = _client.auth.currentUser!.id;
    final extension = file.path.split('.').last;
    final path = '$currentUserId/${messageId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    
    try {
      return await _storageService.uploadFile('chat_attachments', path, file);
    } catch (e) {
      throw Exception('Failed to upload attachment: $e');
    }
  }

  /// Mark messages from a specific sender as read
  Future<void> markMessagesAsRead(String senderId) async {
    final currentUserId = _client.auth.currentUser!.id;
    
    try {
      await _client.from('messages').update({
        'is_read': true
      }).match({
        'sender_id': senderId,
        'receiver_id': currentUserId,
        'is_read': false,
      });
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Get list of conversations with last message and unread count
  Future<List<Conversation>> getConversations() async {
    final currentUserId = _client.auth.currentUser!.id;
    
    try {
      // 1. Fetch all messages involving current user
      final response = await _client.from('messages').select().or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId').order('created_at', ascending: false);
      
      final messages = (response as List).map((json) => Message.fromJson(json)).toList();
      
      // 2. Group by other user
      final Map<String, List<Message>> grouped = {};
      
      for (var m in messages) {
        final otherId = m.senderId == currentUserId ? m.receiverId : m.senderId;
        if (!grouped.containsKey(otherId)) {
          grouped[otherId] = [];
        }
        grouped[otherId]!.add(m);
      }
      
      // 3. Create Conversation objects
      final List<Conversation> conversations = [];
      final Set<String> userIds = grouped.keys.toSet();

      // Fetch profiles
      final profilesResponse = await _client.from('profiles').select().inFilter('user_id', userIds.toList());
      final profiles = (profilesResponse as List).map((json) => UserProfile.fromJson(json)).toList();
      final profileMap = {for (var p in profiles) p.userId: p};

      for (var userId in userIds) {
        final userMessages = grouped[userId]!;
        // Already ordered by created_at desc from query
        final lastMessage = userMessages.first;
        final unreadCount = userMessages.where((m) => m.senderId == userId && !m.isRead).length; // Sender is other user
        
        conversations.add(Conversation(
          otherUserId: userId,
          otherUserProfile: profileMap[userId],
          lastMessage: lastMessage,
          unreadCount: unreadCount,
          lastMessageTime: lastMessage.createdAt,
        ));
      }
      
      // Sort by last message time
      conversations.sort((a, b) => (b.lastMessageTime ?? DateTime(0)).compareTo(a.lastMessageTime ?? DateTime(0)));
      
      return conversations;
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }
  
  /// Stream of total unread count
  Stream<int> getUnreadCountStream() {
    final currentUserId = _client.auth.currentUser!.id;
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .map((data) {
           final messages = data.map((json) => Message.fromJson(json));
           return messages.where((m) => m.receiverId == currentUserId && !m.isRead).length; 
        });
  }

  // Note: Typing indicators and Presence API are not implemented in this version
  // Future implementations would require full Supabase Realtime Presence setup
  
  /*
  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {
     final channel = _client.channel('chat_presence:$conversationId');
     await channel.track({
       'user_id': _client.auth.currentUser!.id,
       'is_typing': isTyping,
     });
  }
  
  Stream<bool> getTypingStatus(String conversationId, String otherUserId)  {
    final channel = _client.channel('chat_presence:$conversationId');
    channel.subscribe();
    return const Stream.empty(); 
  }
  */
}
