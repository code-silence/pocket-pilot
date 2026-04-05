import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Initialize ──
  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // ── Request permission — fixed syntax ──
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  // ── Notification channel details ──
  AndroidNotificationDetails _androidDetails() {
    return const AndroidNotificationDetails(
      'pocket_pilot_channel',
      'PocketPilot Alerts',
      channelDescription: 'Budget and expense reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
  }

  // ── Show instant notification ──
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: _androidDetails()),
    );
  }

  // ── Schedule daily reminder — fixed zonedSchedule ──
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      1,
      'PocketPilot Reminder 💰',
      'Don\'t forget to log your expenses for today!',
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(android: _androidDetails()),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── Budget warning ──
  Future<void> showBudgetWarning({
    required double spent,
    required double limit,
  }) async {
    final percent = ((spent / limit) * 100).toInt();
    await showInstantNotification(
      id: 2,
      title: 'Budget Alert ⚠️',
      body: 'You have used $percent% of your monthly budget. Slow down!',
    );
  }

  // ── Monthly summary ──
  Future<void> scheduleMonthlyReminder() async {
    await _plugin.zonedSchedule(
      3,
      'Monthly Summary 📊',
      'Check your PocketPilot monthly report!',
      _firstDayNextMonth(),
      NotificationDetails(android: _androidDetails()),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  // ── Cancel one ──
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  // ── Cancel all ──
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Helper: next instance of time ──
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ── Helper: first day of next month ──
  tz.TZDateTime _firstDayNextMonth() {
    final now = tz.TZDateTime.now(tz.local);
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextYear = now.month == 12 ? now.year + 1 : now.year;
    return tz.TZDateTime(tz.local, nextYear, nextMonth, 1, 9, 0);
  }
}