import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import 'Screens/login_screen.dart';
import 'Screens/home_screen.dart';
import 'Screens/notes_screen.dart';
import 'Screens/events_screen.dart';
import 'helpers/providers/auth_provider.dart';
import 'helpers/providers/notification_provider.dart';

///HANDLER 
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Registrar background handler
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // Pedir permisos
  await _requestPermission();

  // Inicializar notificaciones locales
  await NotificationProvider().initNotification();

  runApp(const MyApp());
}

/// Permisos
Future<void> _requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Para Android 13+, solicitar POST_NOTIFICATIONS explícitamente
  if (Platform.isAndroid) {
    final status = await Permission.notification.request();
    print('Permiso POST_NOTIFICATIONS: ${status.name}');
  }

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('Permiso Firebase: ${settings.authorizationStatus}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Recordatorios',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const AuthWrapper(),
      routes: {
        '/notes': (context) => const NotesScreen(),
        '/events': (context) => const EventsScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {

  @override
  void initState() {
    super.initState();

    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground: ${message.notification?.title}');
    });

    // Cuando abre la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Abrió notificación');
    });

    _getToken();
  }

  /// Obtener token
  void _getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('📱 TOKEN: $token');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          print('Usuario autenticado: ${snapshot.data!.email}');
          return const HomeScreen();
        }

        print('Usuario no autenticado');
        return const LoginRegisterScreen();
      },
    );
  }
}