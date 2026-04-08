import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'Screens/login_screen.dart';
import 'Screens/home_screen.dart';
import 'Screens/notes_screen.dart';
import 'Screens/events_screen.dart';
import 'helpers/providers/auth_provider.dart';
import 'helpers/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthProvider.initializeFirebase();
  await NotificationProvider().initNotification();
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
      home: const AuthWrapper(),
      routes: {
        '/notes': (context) => const NotesScreen(),
        '/events': (context) => const EventsScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

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