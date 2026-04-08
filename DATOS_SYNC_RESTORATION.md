

### Sincronización
```dart
// Sincroniza TODAS las notas del usuario desde Firebase
await firestoreProvider.syncUserNotes();

// Sincroniza TODOS los eventos del usuario desde Firebase
await firestoreProvider.syncUserEvents();

// Sincroniza TODOS los recordatorios del usuario desde Firebase
await firestoreProvider.syncUserReminders();

// Sincroniza TODO en paralelo (RECOMENDADO)
await firestoreProvider.syncAllUserData();
```

### En `home_screen.dart`
```dart
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Sincronizar datos de Firebase al iniciar la pantalla
    _loadDataFromFirebase();
  }

  Future<void> _loadDataFromFirebase() async {
    if (!_isDataLoaded) {
      print('HomeScreen iniciada - cargando datos de Firebase...');
      await _firestoreProvider.syncAllUserData();
      setState(() {
        _isDataLoaded = true;
      });
    }
  }
}
```

### En `data_provider.dart`
```dart

Future<void> syncUserNotes() async {
  try {
    if (currentUserId == null) return;
    
    print('Sincronizando notas del usuario...');
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
    
    print('${snapshot.docs.length} notas sincronizadas');
  } catch (e) {
    print('Error sincronizando notas: $e');
  }
}
```


##  Estructura de Datos en Firebase

```
Firestore/
└── users/
    └── {userId}/
        ├── notes/
        │   └── {noteId}
        │       ├── title: String
        │       ├── content: String
        │       ├── isPinned: Boolean
        │       ├── createdAt: Timestamp
        │       └── updatedAt: Timestamp
        │
        ├── events/
        │   └── {eventId}
        │       ├── title: String
        │       ├── description: String
        │       ├── date: String
        │       ├── location: String
        │       ├── tag: String
        │       ├── createdAt: Timestamp
        │       └── updatedAt: Timestamp
        │
        └── reminders/
            └── {reminderId}
                ├── date: String
                ├── time: String
                ├── description: String
                ├── createdAt: Timestamp
                └── updatedAt: Timestamp
```