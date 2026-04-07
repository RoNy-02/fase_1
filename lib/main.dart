import 'package:flutter/material.dart';
import 'Screens/login_screen.dart';
import 'Screens/home_screen.dart';
import 'Screens/notes_screen.dart';
import 'Screens/events_screen.dart';
import 'helpers/services/firebase_service.dart';
import 'helpers/services/local_notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  await LocalNotificationsService().initNotification();
  runApp(const MyApp());
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginRegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/notes': (context) => const NotesScreen(),
        '/events': (context) => const EventsScreen(),
      },
    );
  }
}