// Caminho: lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:study_app/constants/app_constants.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Inicializar os dados de timezone
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  static void _handleNotificationPayload(String payload) {
    switch (payload) {
      case AppConstants.reviewNotificationType:
      // Navegar para tela de revisão
        break;
      case AppConstants.studyNotificationType:
      // Navegar para dashboard
        break;
      case AppConstants.goalNotificationType:
      // Navegar para estatísticas
        break;
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'study_app_channel',
      'StudyApp Notifications',
      channelDescription: 'Notificações do aplicativo de estudos',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'study_app_scheduled',
      'StudyApp Scheduled',
      channelDescription: 'Notificações agendadas do StudyApp',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      // 2. CORREÇÃO: Converter DateTime para TZDateTime
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      // 3. CORREÇÃO: Parâmetros atualizados para Android
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'study_app_repeating',
      'StudyApp Repeating',
      channelDescription: 'Notificações recorrentes do StudyApp',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      details,
      payload: payload,
      // 4. CORREÇÃO: Parâmetro atualizado para Android
      androidAllowWhileIdle: true,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> scheduleReviewReminder({
    required String summaryTitle,
    required DateTime reviewDate,
  }) async {
    final id = reviewDate.millisecondsSinceEpoch ~/ 1000;

    await scheduleNotification(
      id: id,
      title: 'Hora de revisar! 📚',
      body: 'É hora de revisar: $summaryTitle',
      scheduledDate: reviewDate,
      payload: AppConstants.reviewNotificationType,
    );
  }

  static Future<void> scheduleStudyReminder({
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(now.location, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleRepeatingNotification(
      id: 999, // ID fixo para lembrete de estudo
      title: 'Hora de estudar! 🎯',
      body: 'Que tal criar alguns resumos hoje?',
      repeatInterval: RepeatInterval.daily,
      payload: AppConstants.studyNotificationType,
    );
  }

  static Future<void> scheduleGoalReminder() async {
    await scheduleRepeatingNotification(
      id: 998, // ID fixo para lembrete de meta
      title: 'Meta diária 🏆',
      body: 'Você ainda não atingiu sua meta de estudos hoje!',
      repeatInterval: RepeatInterval.daily,
      payload: AppConstants.goalNotificationType,
    );
  }

  static Future<bool> areNotificationsEnabled() async {
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      return await androidImpl.areNotificationsEnabled() ?? false;
    }

    return true;
  }

  static Future<void> openNotificationSettings() async {
    // 5. CORREÇÃO: O método foi renomeado/substituído.
    // A ação mais próxima é solicitar a permissão novamente,
    // que em alguns sistemas operacionais leva o usuário às configurações se a permissão foi negada.
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.requestNotificationsPermission();
  }
}