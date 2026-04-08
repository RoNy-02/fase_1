# Integración Firebase - Notas y Eventos por Usuario

## 📋 Resumen
Se ha integrado Firebase para guardar **notas y eventos** de forma personalizada por usuario. Los datos se recuperan automáticamente al iniciar sesión en la cuenta.

---

## 🏗️ Estructura de Datos en Firebase

```
Firestore/
├── users/
│   └── {userId}/
│       ├── notes/
│       │   └── {noteId}
│       │       ├── title: String
│       │       ├── content: String
│       │       ├── isPinned: Boolean
│       │       ├── createdAt: Timestamp
│       │       └── updatedAt: Timestamp
│       │
│       └── events/
│           └── {eventId}
│               ├── title: String
│               ├── description: String
│               ├── date: String (formato: "dd/MM/yyyy HH:mm")
│               ├── location: String
│               ├── tag: String
│               ├── createdAt: Timestamp
│               └── updatedAt: Timestamp
```

---

## 🔧 Cambios Realizados

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

---

## ✨ Características

✅ **Datos Personalizados** - Cada usuario ve solo sus propias notas y eventos  
✅ **Sincronización en Tiempo Real** - Cambios se reflejan inmediatamente gracias a Firestore Streams  
✅ **Recuperación Automática** - Al iniciar sesión, se cargan automáticamente los datos del usuario  
✅ **Sin Almacenamiento Local** - Datos no se guardan en el dispositivo, solo en Firebase  
✅ **Timestamps** - Cada documento registra cuándo se creó y cuándo se modificó  

---

## 🔄 Flujo de Datos

```
Login/Registro
      ↓
Usuario autenticado (Firebase Auth)
      ↓
NavigateTo → HomeScreen / NotesScreen / EventsScreen
      ↓
Screens hacen query a Firestore por userId
      ↓
FirestoreProvider obtiene datos: users/{userId}/notes o events
      ↓
StreamBuilder muestra datos en tiempo real
      ↓
Usuario crea/edita/elimina
      ↓
Métodos de FirestoreProvider actualizan Firestore
      ↓
Firestore actualiza el Stream → StreamBuilder redibuja UI
```

---

## 📝 Ejemplo de Uso

### Guardar una Nota
```dart
final firestoreProvider = FirestoreProvider();

await firestoreProvider.addNote({
  'title': 'Mi Nota',
  'content': 'Contenido de la nota',
  'isPinned': false,
});
// ✅ Se guarda en: users/{userId}/notes/{newDocId}
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
// ✅ Se actualiza en: users/{userId}/events/{eventId}
```

---

## 🔐 Seguridad (Firestore Rules - Recomendado)

Para proteger los datos, agregar estas reglas en Firestore:

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

---

## ✅ Estado Actual

- ✅ Integración completada
- ✅ Guardar notas y eventos
- ✅ Recuperar datos del usuario
- ✅ Editar y eliminar
- ✅ Sincronización en tiempo real
- ✅ Sin errores críticos (flutter analyze)
- ⚠️ Pendiente: Agregar Firestore Rules en Firebase Console (recomendado)

---

## 📱 Próximos Pasos (Opcionales)

1. Agregar Firestore Rules para seguridad
2. Implementar caché offline (para sincronizar cuando hay conexión)
3. Agregar cloud functions para automatizar tareas
4. Implementar búsqueda de notas/eventos
5. Agregar categorías o etiquetas personalizadas
