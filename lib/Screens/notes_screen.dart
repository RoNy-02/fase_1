import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Contenido'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                      final noteData = {
                        'title': titleController.text,
                        'content': contentController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      };

                      if (docId != null) {
                        // Editar nota existente
                        await _firestore.collection('notes').doc(docId).update(noteData);
                      } else {
                        // Agregar nueva nota
                        await _firestore.collection('notes').add(noteData);
                      }

                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, complete todos los campos.')),
                      );
                    }
                  },
                  child: Text(docId != null ? 'Actualizar Nota' : 'Guardar Nota'),
                ),
              ],
            ),
          ),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay notas disponibles. Agrega una nueva usando el botón +.'),
            );
          }

          final notes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
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
                        onPressed: () async {
                          await _firestore.collection('notes').doc(note.id).delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}