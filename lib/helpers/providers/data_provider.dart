import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../models/event.dart';
import '../../models/note.dart';
import '../../models/reminder.dart';

// =================== FirestoreProvider ===================
class FirestoreProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> addData(String collection, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).add(data);
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  Future<void> updateData(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).doc(docId).update(data);
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  Future<void> deleteData(String collection, String docId) async {
    try {
      await _db.collection(collection).doc(docId).delete();
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  Stream<QuerySnapshot> getData(String collection) {
    return _db.collection(collection).snapshots();
  }

  // ========== MÉTODOS DE SINCRONIZACIÓN ==========
  /// Carga todas las notas del usuario desde Firebase
  Future<void> syncUserNotes() async {
    try {
      if (currentUserId == null) return;
      
      print('🔄 Sincronizando notas del usuario...');
      final snapshot = await _db
          .collection('users')
          .doc(currentUserId)
          .collection('notes')
          .get();
      
      // Limpiar notas locales
      NoteProvider().clearNotes();
      
      // Cargar notas desde Firebase
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final note = Note(
          title: data['title'] ?? '',
          content: data['content'] ?? '',
        );
        NoteProvider().addNote(note);
      }
      
      print('👌 ${snapshot.docs.length} notas sincronizadas');
    } catch (e) {
      print('❌ Error sincronizando notas: $e');
    }
  }

  /// Carga todos los eventos del usuario desde Firebase
  Future<void> syncUserEvents() async {
    try {
      if (currentUserId == null) return;
      
      print('🔄 Sincronizando eventos del usuario...');
      final snapshot = await _db
          .collection('users')
          .doc(currentUserId)
          .collection('events')
          .get();
      
      // Limpiar eventos locales
      EventProvider().clearEvents();
      
      // Cargar eventos desde Firebase
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final event = Event(
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: data['date'] ?? '',
          time: data['date']?.split(' ')[1] ?? '',
          location: data['location'] ?? '',
        );
        EventProvider().addEvent(event);
      }
      
      print('👍 ${snapshot.docs.length} eventos sincronizados');
    } catch (e) {
      print('❌ Error sincronizando eventos: $e');
    }
  }

  /// Carga todos los recordatorios del usuario desde Firebase (preparado para futura expansión)
  Future<void> syncUserReminders() async {
    try {
      if (currentUserId == null) return;
      
      print('🔄 Sincronizando recordatorios del usuario...');
      final snapshot = await _db
          .collection('users')
          .doc(currentUserId)
          .collection('reminders')
          .get();
      
      // Limpiar recordatorios locales
      ReminderProvider().clearReminders();
      
      // Cargar recordatorios desde Firebase
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final reminder = Reminder(
          date: data['date'] ?? '',
          time: data['time'] ?? '',
          description: data['description'] ?? '',
        );
        ReminderProvider().addReminder(reminder);
      }
      
      print(' ${snapshot.docs.length} recordatorios sincronizados');
    } catch (e) {
      print(' Error sincronizando recordatorios: $e');
    }
  }

  /// Sincroniza todos los datos del usuario (notas, eventos, recordatorios)
  Future<void> syncAllUserData() async {
    try {
      print('\n📱 Iniciando sincronización completa de datos...');
      await Future.wait([
        syncUserNotes(),
        syncUserEvents(),
        syncUserReminders(),
      ]);
      print(' Sincronización completada\n');
    } catch (e) {
      print(' Error en sincronización completa: $e');
    }
  }

  // ========== MÉTODOS PARA NOTAS CON USUARIO ==========
  Future<void> addNote(Map<String, dynamic> noteData) async {
    try {
      if (currentUserId != null) {
        await _db
            .collection('users')
            .doc(currentUserId)
            .collection('notes')
            .add({
          ...noteData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  Future<void> updateNote(String noteId, Map<String, dynamic> noteData) async {
    try {
      if (currentUserId != null) {
        await _db
            .collection('users')
            .doc(currentUserId)
            .collection('notes')
            .doc(noteId)
            .update({
          ...noteData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      if (currentUserId != null) {
        await _db
            .collection('users')
            .doc(currentUserId)
            .collection('notes')
            .doc(noteId)
            .delete();
      }
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  Stream<QuerySnapshot> getUserNotes() {
    if (currentUserId == null) {
      return const Stream.empty();
    }
    return _db
        .collection('users')
        .doc(currentUserId)
        .collection('notes')
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // ========== MÉTODOS PARA EVENTOS CON USUARIO ==========
  Future<void> addEvent(Map<String, dynamic> eventData) async {
    try {
      if (currentUserId != null) {
        await _db
            .collection('users')
            .doc(currentUserId)
            .collection('events')
            .add({
          ...eventData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    try {
      if (currentUserId != null) {
        await _db
            .collection('users')
            .doc(currentUserId)
            .collection('events')
            .doc(eventId)
            .update({
          ...eventData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      if (currentUserId != null) {
        await _db
            .collection('users')
            .doc(currentUserId)
            .collection('events')
            .doc(eventId)
            .delete();
      }
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  Stream<QuerySnapshot> getUserEvents() {
    if (currentUserId == null) {
      return const Stream.empty();
    }
    return _db
        .collection('users')
        .doc(currentUserId)
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

// =================== EventProvider ===================
class EventProvider extends ChangeNotifier {
  static final EventProvider _instance = EventProvider._internal();

  List<Event> _events = [];

  EventProvider._internal();

  factory EventProvider() {
    return _instance;
  }

  List<Event> get events => _events;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void removeEvent(int index) {
    if (index >= 0 && index < _events.length) {
      _events.removeAt(index);
      notifyListeners();
    }
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }
}

// =================== ReminderProvider ===================
class ReminderProvider {
  static final ReminderProvider _instance = ReminderProvider._internal();

  late List<Reminder> _reminders;

  ReminderProvider._internal() {
    _reminders = [];
  }

  factory ReminderProvider() {
    return _instance;
  }

  List<Reminder> get reminders => _reminders;

  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
  }

  void removeReminder(int index) {
    if (index >= 0 && index < _reminders.length) {
      _reminders.removeAt(index);
    }
  }

  void clearReminders() {
    _reminders.clear();
  }
}

// =================== NoteProvider ===================
class NoteProvider {
  static final NoteProvider _instance = NoteProvider._internal();

  late List<Note> _notes;

  NoteProvider._internal() {
    _notes = [];
  }

  factory NoteProvider() {
    return _instance;
  }

  List<Note> get notes => _notes;

  void addNote(Note note) {
    _notes.add(note);
  }

  void removeNote(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index);
    }
  }

  void clearNotes() {
    _notes.clear();
  }
}
