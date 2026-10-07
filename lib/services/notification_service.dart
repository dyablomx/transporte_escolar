import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';

class NotificationService {
  static Future<void> guardarHoraRecordatorio({
    required int hora,
    required int minuto,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('hora_recordatorio', hora);
    await prefs.setInt('minuto_recordatorio', minuto);
  }

  static Future<int> obtenerHoraRecordatorio() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt('hora_recordatorio') ?? 12;
  }

  static Future<int> obtenerMinutoRecordatorio() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt('minuto_recordatorio') ?? 0;
  }

  static void Function()? alTocarNotificacion;

  static Future<void> cancelarRecordatorio() async {
    await _notifications.cancel(id: 1);
  }

  static void _alTocarNotificacion(NotificationResponse response) {
    alTocarNotificacion?.call();
  }

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicializar() async {
    tz.initializeTimeZones();

    final zonaHoraria = await FlutterNativeTimezoneLatest.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(zonaHoraria));

    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_bus',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _alTocarNotificacion,
    );
  }

  static Future<void> solicitarPermisos() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  static Future<void> programarRecordatorio({
    int hora = 12,
    int minuto = 0,
  }) async {
    await cancelarRecordatorio();

    final fechaProgramada = _siguienteHorario(hora, minuto);

    await _notifications.zonedSchedule(
      id: 1,
      title: 'Transporte escolar JAIXOT',
      body: 'Es hora de llenar el reporte. Ruta Zumpango - Reyes.',
      scheduledDate: fechaProgramada,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'recordatorio_diario',
          'Recordatorio diario',
          channelDescription:
              'Recordatorio para llenar el formato diario de transporte.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _siguienteHorario(int hora, int minuto) {
    final ahora = tz.TZDateTime.now(tz.local);

    var programado = tz.TZDateTime(
      tz.local,
      ahora.year,
      ahora.month,
      ahora.day,
      hora,
      minuto,
    );

    if (programado.isBefore(ahora)) {
      programado = programado.add(const Duration(days: 1));
    }

    return programado;
  }
}
