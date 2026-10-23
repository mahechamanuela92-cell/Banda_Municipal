import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ServicioNotificaciones {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Llamar una sola vez en main() antes de runApp
  static Future<void> iniciar() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    // Pide permiso de notificaciones en Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Programa un aviso un día antes del evento.
  /// Devuelve false si el evento está a menos de 24 horas.
  static Future<bool> programarRecordatorio({
    required int id,
    required String titulo,
    required String cuerpo,
    required DateTime fechaEvento,
  }) async {
    final DateTime fechaAviso = fechaEvento.subtract(const Duration(days: 1));
    if (fechaAviso.isBefore(DateTime.now())) return false;

    await _plugin.zonedSchedule(
      id,
      titulo,
      cuerpo,
      tz.TZDateTime.from(fechaAviso, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recordatorios_eventos',
          'Recordatorios de eventos',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    return true;
  }
}