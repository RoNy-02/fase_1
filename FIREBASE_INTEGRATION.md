# Integración Firebase - Notas y Eventos por Usuario




### 1. **data_provider.dart** (Modificado)
Agregados métodos en `FirestoreProvider`:

**Para Notas:**
- `addNote(Map<String, dynamic> noteData)` - Guardar nueva nota
- `updateNote(String noteId, Map<String, dynamic> noteData)` - Editar nota
- `deleteNote(String noteId)` - Eliminar nota
- `getUserNotes()` - Stream de notas del usuario actual

**Para Eventos:**
- `addEvent(Map<String, dynamic> eventData)` - Guardar nuevo evento
- `updateEvent(String eventId, Map<String, dynamic> eventData)` - Editar evento
- `deleteEvent(String eventId)` - Eliminar evento
- `getUserEvents()` - Stream de eventos del usuario actual

### 2. **notes_screen.dart** (Modificado)
- Usa `FirestoreProvider().getUserNotes()` para obtener notas
- Guarda notas en la estructura `users/{userId}/notes`
- Mantiene interfaz de edición y eliminación

### 3. **events_screen.dart** (Modificado)
- Usa `FirestoreProvider().getUserEvents()` para obtener eventos
- Guarda eventos en la estructura `users/{userId}/events`
- Mantiene interfaz de edición y eliminación

### 4. **home_screen.dart** (Modificado)
- Al guardar "Nota Rápida", se guarda en Firebase y localmente
- Usa `FirestoreProvider.addNote()` para persistencia


### Guardar una Nota
```dart
final firestoreProvider = FirestoreProvider();

await firestoreProvider.addNote({
  'title': 'Mi Nota',
  'content': 'Contenido de la nota',
  'isPinned': false,
});
//  Se guarda en: users/{userId}/notes/{newDocId}
```

### Obtener Notas del Usuario
```dart
StreamBuilder<QuerySnapshot>(
  stream: _firestoreProvider.getUserNotes(),
  builder: (context, snapshot) {
    // snapshot.data?.docs contiene todas las notas del usuario
  },
)
```

### Editar un Evento
```dart
await firestoreProvider.updateEvent(eventId, {
  'title': 'Evento Actualizado',
  'description': 'Nueva descripción',
  'date': '07/04/2026 14:30',
  'location': 'Nueva ubicación',
  'tag': 'personal',
});
//  Se actualiza en: users/{userId}/events/{eventId}
```

---

##  Seguridad o reglas para la base de datos

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```
