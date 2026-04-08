import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/providers/data_provider.dart';

class NotesScreen extends StatefulWidget {
  final List<Map<String, String>> notes;

  const NotesScreen({Key? key, this.notes = const []}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final FirestoreProvider _firestoreProvider = FirestoreProvider();

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
                    'isPinned': existingNote?['isPinned'] ?? false,
                  };

                  Navigator.pop(context);

                  if (docId != null) {
                    // Editar nota existente
                    await _firestoreProvider.updateNote(docId, noteData);
                  } else {
                    // Agregar nueva nota
                    await _firestoreProvider.addNote(noteData);
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
        stream: _firestoreProvider.getUserNotes(),
        builder: (context, snapshot) {
          final localNotes = NoteProvider().notes;
          final firebaseNotes = snapshot.data?.docs ?? [];
          
          if (snapshot.connectionState == ConnectionState.waiting && localNotes.isEmpty && firebaseNotes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (localNotes.isEmpty && firebaseNotes.isEmpty) {
            return const Center(
              child: Text('No hay notas disponibles. Agrega una nueva usando el botón +.'),
            );
          }

          // Separar notas pinneadas de las no pinneadas
          final pinnedNotes = firebaseNotes.where((doc) => (doc.data() as Map<String, dynamic>)['isPinned'] ?? false).toList();
          final unpinnedNotes = firebaseNotes.where((doc) => !((doc.data() as Map<String, dynamic>)['isPinned'] ?? false)).toList();
          final sortedNotes = [...pinnedNotes, ...unpinnedNotes];

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: localNotes.length + sortedNotes.length,
            itemBuilder: (context, index) {
              final colors = [
                Colors.blue.shade50,
                Colors.green.shade50,
                Colors.orange.shade50,
                Colors.purple.shade50,
                Colors.pink.shade50,
                Colors.yellow.shade50,
              ];
              final backgroundColor = colors[index % colors.length];
              
              // Mostrar notas locales primero
              if (index < localNotes.length) {
                final localNote = localNotes[index];
                return Card(
                  color: backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localNote.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            localNote.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
                                      onPressed: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          NoteProvider().removeNote(index);
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('✅ Nota eliminada'),
                                            duration: Duration(seconds: 2),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
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
              } else {
                // Mostrar notas de Firebase después (ordenadas: pinneadas primero)
                final firebaseIndex = index - localNotes.length;
                final note = sortedNotes[firebaseIndex];
                final isPinned = (note.data() as Map<String, dynamic>)['isPinned'] ?? false;
                
                return Card(
                  color: backgroundColor,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note['title']!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                note['content']!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () {
                                    _addOrEditNote(docId: note.id, existingNote: note.data() as Map<String, dynamic>);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
                                                await _firestoreProvider.deleteNote(note.id);
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
                          ],
                        ),
                      ),
                      // Botón Pin en la esquina superior derecha
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(
                            isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            color: isPinned ? Colors.orange : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () async {
                            await _firestoreProvider.updateNote(note.id, {
                              'title': note['title'],
                              'content': note['content'],
                              'isPinned': !isPinned,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isPinned ? '📌 Nota desanclada' : '📌 Nota anclada'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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