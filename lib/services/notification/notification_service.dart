import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/appointment.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Android Config
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Standard Flutter icon

    // iOS Config
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> showImmediateNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'safe_space_channel',
      'Safe Space Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // Simple ID
      title,
      body,
      details,
    );
  }

  Future<void> scheduleAppointmentNotification(Appointment appointment) async {
    // Schedule 1 hour before
    final scheduledTime = appointment.startTime.subtract(const Duration(hours: 1));
    
    if (scheduledTime.isBefore(DateTime.now())) return; // Too late to schedule

    await _notificationsPlugin.zonedSchedule(
      appointment.id.hashCode, // Unique Int ID
      'Upcoming Session',
      'Your session with your mentor starts in 1 hour.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'safe_space_appointments',
          'Appointment Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int notificationId) async {
    await _notificationsPlugin.cancel(notificationId);
  }

  Future<void> showChatNotification(String senderName, String messagePreview) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'safe_space_chat',
      'Chat Messages',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      senderName,
      messagePreview.length > 100 
          ? '${messagePreview.substring(0, 100)}...' 
          : messagePreview,
      details,
    );
  }
}
