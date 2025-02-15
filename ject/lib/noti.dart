import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

// Background task identifier
const String taskName = "showNotificationTask";

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize WorkManager for background notifications
  Future<void> initializeWorkManager() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize WorkManager
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    // Register a periodic task
    await Workmanager().registerPeriodicTask(
      "1",
      taskName,
      frequency: Duration(minutes: 1), // Minimum allowed time interval for WorkManager
    );
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
        0, 'Hello!', 'This is a notification every 5 seconds.', details);
  }

  void startRepeatingNotifications() {
    Future.delayed(Duration(seconds: 5), () {
      _showNotification();
      startRepeatingNotifications();
    });
  }
}

// Background callback for WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(settings);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
        0, 'Hello!', 'This is a background notification.', details);

    return Future.value(true);
  });
}
