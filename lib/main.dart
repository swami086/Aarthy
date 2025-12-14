import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/theme/app_theme.dart';
import 'utils/router/app_router.dart';
import 'utils/constants/app_constants.dart';
import 'services/notification/notification_service.dart';
import 'viewmodels/viewmodels.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseUrl.isEmpty || supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      throw Exception('Missing Supabase configuration. Please check your .env file.');
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );

    // Initialize Notifications
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  RealtimeChannel? _messageChannel;
  bool _isAppInForeground = true;
  String? _currentChatUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupMessageListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageChannel?.unsubscribe();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isAppInForeground = state == AppLifecycleState.resumed;
    });
  }

  void _setupMessageListener() {
    final supabase = Supabase.instance.client;
    
    // Listen to auth state changes to update listener
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _setupRealtimeListener(session.user.id);
      } else {
        _messageChannel?.unsubscribe();
        _messageChannel = null;
      }
    });
  }

  void _setupRealtimeListener(String currentUserId) {
    _messageChannel?.unsubscribe();
    
    _messageChannel = Supabase.instance.client
        .channel('messages:$currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: currentUserId,
          ),
          callback: (payload) {
            final newMessage = payload.newRecord;
            
            // Only show notification if app is in background and not viewing this chat
            if (!_isAppInForeground || _currentChatUserId != newMessage['sender_id']) {
              _showChatNotification(newMessage);
            }
          },
        )
        .subscribe();
  }

  Future<void> _showChatNotification(Map<String, dynamic> messageData) async {
    final senderId = messageData['sender_id'] as String;
    final content = messageData['content'] as String? ?? '';
    final attachmentType = messageData['attachment_type'] as String?;
    
    // Fetch sender profile for name
    try {
      final profile = await ref.read(userProfileProvider(senderId).future);
      final senderName = profile?.displayName ?? 'Someone';
      
      String messagePreview = content;
      if (messagePreview.isEmpty && attachmentType != null) {
        messagePreview = attachmentType == 'image' ? '📷 Photo' : '📎 Attachment';
      }
      
      await NotificationService().showChatNotification(senderName, messagePreview);
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    
    // Track current route to avoid duplicate notifications
    router.routerDelegate.addListener(() {
      final location = router.routerDelegate.currentConfiguration.uri.path;
      if (location.startsWith('/chat/')) {
        _currentChatUserId = location.split('/').last;
      } else {
        _currentChatUserId = null;
      }
    });
    
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
