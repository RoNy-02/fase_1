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

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

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
    int notificationId,
  ) async {
    print('🔔 ========== scheduleNotification LLAMADA ==========');
    print('   Título: $title | Desc: $description');
    print('   Hora: $scheduledTime | ID: $notificationId');
    try {
      // Verificar y solicitar permisos ANTES de programar
      final hasPermission = await _ensurePermission();
      if (!hasPermission) {
        print('⚠️ Permiso de notificación denegado');
        return;
      }

      final DateTime notificationTime =
          scheduledTime.subtract(Duration(minutes: minutesBefore));
      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(notificationTime, tz.local);

      // Convertir ID a un rango válido (0 a 2147483647)
      final int safeId = (notificationId % 2147483647).abs();
      
      print('📅 Fecha y hora ingresada: $scheduledTime');
      print('⏰ Hora actual: ${DateTime.now()}');
      print('🆔 ID de notificación: $safeId');
      print('📲 Programando para: ${tzScheduledTime.toString()}');

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

      print('📲 Programando notificación:');
      print('   Título: $title');
      print('   Descripción: $description');
      print('   ID: $safeId');
      
      await _notificationsPlugin.zonedSchedule(
        safeId,
        title,
        description,
        tzScheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ NOTIFICACIÓN PROGRAMADA (ID: $safeId)');
    } catch (e) {
      print('❌ ERROR CAPTURADO: $e type: ${e.runtimeType}');
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> showTestNotification(String title, String description) async {
    print('🧪 ========== MOSTRANDO NOTIFICACIÓN DE PRUEBA ==========');
    print('   Título: $title');
    print('   Descripción: $description');
    
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
      final int uniqueId = DateTime.now().millisecondsSinceEpoch.toInt() % 2147483647;
      print('   ID: $uniqueId');
      print('   LLAMANDO: _notificationsPlugin.show()');
      
      await _notificationsPlugin.show(
        uniqueId,
        title,
        description,
        platformChannelSpecifics,
      );
      
      print('✅ NOTIFICACIÓN DE PRUEBA MOSTRADA EXITOSAMENTE');
    } catch (e) {
      print('❌ ERROR MOSTRAND NOTIFICACIÓN: $e');
      print('   Tipo: ${e.runtimeType}');
    }
  }
}

