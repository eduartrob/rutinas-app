import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Servicio de notificaciones locales para hábitos
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Inicializar timezone
    tz_data.initializeTimeZones();

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
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

    _isInitialized = true;
    debugPrint('🔔 NotificationService: Inicializado');
  }

  /// Manejar tap en notificación
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notificación tocada: ${response.payload}');
    // TODO: Navegar a la pantalla del hábito
  }

  /// Solicitar permisos de notificaciones
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      debugPrint('🔔 Permiso de notificaciones: $status');
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  /// Verificar si tiene permisos
  Future<bool> hasPermissions() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    return true;
  }

  /// Programar notificación para un hábito
  Future<void> scheduleHabitNotification({
    required int id,
    required String habitName,
    required String habitEmoji,
    required TimeOfDay time,
    String? routineName,
  }) async {
    final hasPermission = await hasPermissions();
    if (!hasPermission) {
      debugPrint('🔔 Sin permisos de notificación');
      return;
    }

    // Calcular la próxima hora de notificación
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Si la hora ya pasó hoy, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'habits_channel',
      'Recordatorios de Hábitos',
      channelDescription: 'Notificaciones para tus hábitos diarios',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      '$habitEmoji $habitName',
      routineName != null 
          ? '¡Es hora de tu hábito de $routineName!' 
          : '¡Es hora de completar este hábito!',
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repetir diariamente
      payload: 'habit_$id',
    );

    debugPrint('🔔 Notificación programada: $habitName a las ${time.hour}:${time.minute}');
  }

  /// Cancelar notificación de un hábito
  Future<void> cancelHabitNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('🔔 Notificación cancelada: ID $id');
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🔔 Todas las notificaciones canceladas');
  }

  /// Mostrar notificación inmediata (para testing)
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test',
      channelDescription: 'Canal de prueba',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      '🎉 ¡Notificaciones activadas!',
      'Recibirás recordatorios de tus hábitos',
      notificationDetails,
    );
  }

  /// Programar notificaciones para todos los hábitos de una rutina
  Future<void> scheduleRoutineNotifications({
    required String routineId,
    required String routineName,
    required List<({String id, String name, String emoji, String? time})> habits,
  }) async {
    int notificationId = routineId.hashCode;

    for (final habit in habits) {
      if (habit.time != null && habit.time!.isNotEmpty) {
        final timeParts = habit.time!.split(':');
        if (timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;

          await scheduleHabitNotification(
            id: notificationId + habit.id.hashCode,
            habitName: habit.name,
            habitEmoji: habit.emoji,
            time: TimeOfDay(hour: hour, minute: minute),
            routineName: routineName,
          );
        }
      }
    }
  }
}
