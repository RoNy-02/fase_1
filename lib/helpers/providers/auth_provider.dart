import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase_options.dart';

class AuthProvider {
  static final AuthProvider _instance = AuthProvider._internal();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  factory AuthProvider() {
    return _instance;
  }

  AuthProvider._internal();

  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
