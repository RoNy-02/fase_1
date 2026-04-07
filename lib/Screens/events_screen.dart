import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final CollectionReference _eventsCollection =
      FirebaseFirestore.instance.collection('events');

  void _addOrEditEvent({Map<String, String>? existingEvent, int? index}) {
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
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        dateController.text.isNotEmpty &&
                        timeController.text.isNotEmpty &&
                        locationController.text.isNotEmpty) {
                      final newEvent = {
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'date': '${dateController.text} ${timeController.text}',
                        'location': locationController.text,
                        'tag': existingEvent?['tag'] ?? 'personal',
                      };

                      if (existingEvent != null && index != null) {
                        final docId = existingEvent['id'];
                        if (docId != null) {
                          await _eventsCollection.doc(docId).update(newEvent);
                        }
                      } else {
                        await _eventsCollection.add(newEvent);
                      }

                      setState(() {});
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, complete todos los campos.')),
                      );
                    }
                  },
                  child: Text(existingEvent != null ? 'Actualizar Evento' : 'Guardar Evento'),
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
        stream: _eventsCollection.snapshots(),
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
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data() as Map<String, dynamic>;
              return Card(
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
                      Chip(label: Text(event['tag'] ?? 'personal')),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _addOrEditEvent(
                            existingEvent: Map<String, String>.from(event),
                            index: index,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _eventsCollection.doc(events[index].id).delete();
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