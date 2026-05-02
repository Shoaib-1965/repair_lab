import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

    // Create Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'jtc_lab_alerts',
            'JTC Lab Alerts',
            description: 'Notifications for JTC Repair Lab',
            importance: Importance.high,
          ),
        );

    // Request notification permission for Android
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();

    // iOS requests permission automatically in DarwinInitializationSettings
  }

  static void _notificationTapBackground(
    NotificationResponse notificationResponse,
  ) {
    // Handle background notification tap
  }

  /// Show notification for new repair job added
  Future<void> showNewJobNotification(
    String customerName,
    String deviceModel,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'jtc_lab_alerts',
          'JTC Lab Alerts',
          channelDescription: 'Notifications for JTC Repair Lab',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'New Job Added',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'New Job Added ✅',
      '$customerName - $deviceModel',
      platformChannelSpecifics,
    );
  }

  /// Show notification for repair job completed
  Future<void> showJobCompleteNotification(
    String customerName,
    String deviceModel,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'jtc_lab_alerts',
          'JTC Lab Alerts',
          channelDescription: 'Notifications for JTC Repair Lab',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Repair Complete',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      1,
      'Repair Complete 🎉',
      '$customerName - $deviceModel',
      platformChannelSpecifics,
    );
  }

  /// Show notification for issue found on job
  Future<void> showIssueFoundNotification(String issueNote) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'jtc_lab_alerts',
          'JTC Lab Alerts',
          channelDescription: 'Notifications for JTC Repair Lab',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Issue Found',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      2,
      'Issue Found ⚠️',
      issueNote,
      platformChannelSpecifics,
    );
  }

  /// Show notification for borrow item added
  Future<void> showBorrowItemNotification(
    String partName,
    String shopName,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'jtc_lab_alerts',
          'JTC Lab Alerts',
          channelDescription: 'Notifications for JTC Repair Lab',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Part Borrowed',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      3,
      'Part Borrowed 📦',
      '$partName from $shopName',
      platformChannelSpecifics,
    );
  }
}
