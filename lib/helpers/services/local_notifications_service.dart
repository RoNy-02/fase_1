import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory LocalNotificationsService() {
    return _instance;
  }

  LocalNotificationsService._internal();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // Crear el canal de notificaciones para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      'Recordatorios',
      description: 'Canal para recordatorios de la aplicación',
      importance: Importance.high,
      enableVibration: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    await androidImplementation?.createNotificationChannel(channel);
    print('✅ Servicio de notificaciones inicializado');
  }

  // Verificar y solicitar permiso de notificaciones
  Future<bool> _ensurePermission() async {
    if (!Platform.isAndroid) return true; // No hay restricciones en iOS
    
    final PermissionStatus status = await Permission.notification.status;
    print('📱 Estado de permiso: ${status.name}');

    if (status.isDenied) {
      // Solicitar permiso
      final PermissionStatus result = await Permission.notification.request();
      print(result.isGranted 
          ? '✅ Permiso otorgado' 
          : '❌ Permiso denegado: ${result.name}');
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // Abrir configuración de la app
      print('⚠️ Permiso denegado permanentemente, abriendo configuración');
      openAppSettings();
      return false;
    } else if (status.isGranted) {
      print('✅ Permiso ya otorgado');
      return true;
    }
    
    return status.isGranted;
  }

  Future<void> scheduleNotification(
    String title,
    String description,
    DateTime scheduledTime,
    int minutesBefore,
  ) async {
    // Asegurar que tenemos permiso antes de programar
    final bool hasPermission = await _ensurePermission();
    if (!hasPermission) {
      print('❌ No se puede programar notificación sin permiso');
      return;
    }

    try {
      final DateTime notificationTime =
          scheduledTime.subtract(Duration(minutes: minutesBefore));
      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(notificationTime, tz.local);

      // Validar que la hora no esté en el pasado
      final tz.TZDateTime nowTZ = tz.TZDateTime.now(tz.local);
      if (tzScheduledTime.isBefore(nowTZ)) {
        print('⚠️ La hora de notificación está en el pasado, se mostrará inmediatamente');
        await showTestNotification(title, description);
        return;
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'reminder_channel',
        'Recordatorios',
        channelDescription: 'Canal para recordatorios de la aplicación',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      final int uniqueId = scheduledTime.millisecondsSinceEpoch.toInt();

      await _notificationsPlugin.zonedSchedule(
        uniqueId,
        title,
        description,
        tzScheduledTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ Notificación programada para: ${tzScheduledTime.toString()} (ID: $uniqueId)');
    } catch (e) {
      print('❌ Error al programar notificación: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> showTestNotification(String title, String description) async {
    // Asegurar que tenemos permiso antes de mostrar
    final bool hasPermission = await _ensurePermission();
    if (!hasPermission) {
      print('❌ No se puede mostrar notificación sin permiso');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel',
      'Recordatorios',
      channelDescription: 'Canal para recordatorios de la aplicación',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      final int uniqueId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _notificationsPlugin.show(
        uniqueId,
        title,
        description,
        platformChannelSpecifics,
      );
      print(' Notificación de prueba mostrada (ID: $uniqueId)');
    } catch (e) {
      print(' Error mostrando notificación de prueba: $e');
    }
  }
}
