import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/services/note_service.dart';

class NotesScreen extends StatefulWidget {
  final List<Map<String, String>> notes;

  const NotesScreen({Key? key, this.notes = const []}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addOrEditNote({String? docId, Map<String, dynamic>? existingNote}) {
    final TextEditingController titleController = TextEditingController(
      text: existingNote?['title'] ?? '',
    );
    final TextEditingController contentController = TextEditingController(
      text: existingNote?['content'] ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(docId != null ? 'Editar Nota' : 'Crear Nueva Nota'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Contenido'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  final noteData = {
                    'title': titleController.text,
                    'content': contentController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  };

                  Navigator.pop(context);

                  if (docId != null) {
                    // Editar nota existente
                    await _firestore.collection('notes').doc(docId).update(noteData);
                  } else {
                    // Agregar nueva nota
                    await _firestore.collection('notes').add(noteData);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos.')),
                  );
                }
              },
              child: Text(docId != null ? 'Actualizar Nota' : 'Guardar Nota'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        backgroundColor: const Color.fromARGB(255, 160, 19, 66),
        child: const Icon(Icons.add),
      ),      appBar: AppBar(
        title: const Text('Notas'),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('notes').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          final localNotes = NoteService().notes;
          final firebaseNotes = snapshot.data?.docs ?? [];
          
          if (snapshot.connectionState == ConnectionState.waiting && localNotes.isEmpty && firebaseNotes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (localNotes.isEmpty && firebaseNotes.isEmpty) {
            return const Center(
              child: Text('No hay notas disponibles. Agrega una nueva usando el botón +.'),
            );
          }

          return ListView.builder(
            itemCount: localNotes.length + firebaseNotes.length,
            itemBuilder: (context, index) {
              // Mostrar notas locales primero
              if (index < localNotes.length) {
                final localNote = localNotes[index];
                return Card(
                  color: Colors.blue.shade50,
                  child: ListTile(
                    title: Text(localNote.title),
                    subtitle: Text(localNote.content),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          NoteService().removeNote(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Nota eliminada'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                // Mostrar notas de Firebase después
                final firebaseIndex = index - localNotes.length;
                final note = firebaseNotes[firebaseIndex];
                return Card(
                  child: ListTile(
                    title: Text(note['title']!),
                    subtitle: Text(note['content']!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _addOrEditNote(docId: note.id, existingNote: note.data() as Map<String, dynamic>);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Eliminar Nota'),
                                  content: const Text('¿Estás seguro de que deseas eliminar esta nota?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _firestore.collection('notes').doc(note.id).delete();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}