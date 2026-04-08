import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../helpers/providers/data_provider.dart';
import '../models/event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final FirestoreProvider _firestoreProvider = FirestoreProvider();

  void _addOrEditEvent({Map<String, dynamic>? existingEvent, String? docId, int? index}) {
    final TextEditingController titleController = TextEditingController(
      text: existingEvent?['title'] ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: existingEvent?['description'] ?? '',
    );
    
    String? existingDate = existingEvent?['date'];
    String datePart = '';
    String timePart = '';
    
    if (existingDate != null && existingDate.contains(' ')) {
      final parts = existingDate.split(' ');
      datePart = parts[0];
      timePart = parts.length > 1 ? parts[1] : '';
    }
    
    final TextEditingController dateController = TextEditingController(
      text: datePart,
    );
    final TextEditingController timeController = TextEditingController(
      text: timePart,
    );
    final TextEditingController locationController = TextEditingController(
      text: existingEvent?['location'] ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(docId != null ? 'Editar Evento' : 'Crear Nuevo Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha (ejemplo: 06/04/2026)',
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020, 1, 1),
                      lastDate: DateTime(2100, 12, 31),
                    );
                    if (pickedDate != null) {
                      dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                    }
                  },
                ),
                TextField(
                  controller: timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Hora (ejemplo: 14:30)',
                  ),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      timeController.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                    }
                  },
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
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
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    timeController.text.isNotEmpty &&
                    locationController.text.isNotEmpty) {
                  
                  Navigator.pop(context);
                  
                  final newEvent = {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'date': '${dateController.text} ${timeController.text}',
                    'location': locationController.text,
                    'tag': existingEvent?['tag'] ?? 'personal',
                  };

                  if (docId != null) {
                    // Editar evento existente
                    await _firestoreProvider.updateEvent(docId, newEvent);
                  } else {
                    // Agregar nuevo evento
                    await _firestoreProvider.addEvent(newEvent);
                    
                    // Guardar evento en el servicio local
                    final event = Event(
                      title: titleController.text,
                      description: descriptionController.text,
                      date: dateController.text,
                      time: timeController.text,
                      location: locationController.text,
                    );
                    EventProvider().addEvent(event);
                  }

                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, complete todos los campos.')),
                  );
                }
              },
              child: Text(docId != null ? 'Actualizar Evento' : 'Guardar Evento'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditEvent(),
        backgroundColor: const Color.fromARGB(255, 160, 19, 66),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Eventos'),
        backgroundColor: const Color.fromARGB(255, 156, 39, 176),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreProvider.getUserEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay eventos disponibles. Agrega uno nuevo usando el botón +.'),
            );
          }

          final events = snapshot.data!.docs;
          final colors = [
            Colors.blue.shade50,
            Colors.green.shade50,
            Colors.orange.shade50,
            Colors.purple.shade50,
            Colors.pink.shade50,
            Colors.yellow.shade50,
          ];
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data() as Map<String, dynamic>;
              final backgroundColor = colors[index % colors.length];
              return Card(
                color: backgroundColor,
                child: ListTile(
                  title: Text(event['title'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['description'] ?? ''),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 4),
                          Text(event['date']?.split(' ')[0] ?? ''),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(event['date']?.split(' ')[1] ?? ''),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Text(event['location'] ?? ''),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _addOrEditEvent(
                            existingEvent: event,
                            docId: events[index].id,
                            index: index,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Eliminar Evento'),
                                content: const Text('¿Estás seguro de que deseas eliminar este evento?'),
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
                                      await _firestoreProvider.deleteEvent(events[index].id);
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
            },
          );
        },
      ),
    );
  }
}