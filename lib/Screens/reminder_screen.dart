import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../helpers/services/local_notifications_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final CollectionReference _remindersCollection =
      FirebaseFirestore.instance.collection('reminders');
  final LocalNotificationsService _notificationsService =
      LocalNotificationsService();

  Future<void> _scheduleNotification(String title, String description, DateTime scheduledTime, int minutesBefore) async {
    await _notificationsService.scheduleNotification(
      title,
      description,
      scheduledTime,
      minutesBefore,
    );
  }

  Future<void> _addOrEditReminder({Map<String, String>? existingReminder, int? index}) async {
    final TextEditingController titleController = TextEditingController(
      text: existingReminder?['title'] ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: existingReminder?['description'] ?? '',
    );
    
    String? existingDate = existingReminder?['date'];
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
    //tiempo antes de la notificacion
    int notificationMinutesBefore = int.tryParse(existingReminder?['notificationMinutesBefore'] ?? '15') ?? 15;

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
                const SizedBox(height: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notificar antes de:'),
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return DropdownButton<int>(
                          value: notificationMinutesBefore,
                          items: const [
                            DropdownMenuItem(
                              value: 1,
                              child: Text('1 minuto'),
                            ),
                            DropdownMenuItem(
                              value: 5,
                              child: Text('5 minutos'),
                            ),
                            DropdownMenuItem(
                              value: 10,
                              child: Text('10 minutos'),
                            ),
                            DropdownMenuItem(
                              value: 15,
                              child: Text('15 minutos'),
                            ),
                            DropdownMenuItem(
                              value: 30,
                              child: Text('30 minutos'),
                            ),
                            DropdownMenuItem(
                              value: 60,
                              child: Text('1 hora'),
                            ),
                          ],
                          onChanged: (int? value) {
                            setState(() {
                              notificationMinutesBefore = value ?? 15;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        dateController.text.isNotEmpty &&
                        timeController.text.isNotEmpty) {
                      final newReminder = {
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'date': '${dateController.text} ${timeController.text}',
                        'notificationMinutesBefore': notificationMinutesBefore.toString(),
                      };

                      if (existingReminder != null && index != null) {
                        final docId = existingReminder['id'];
                        if (docId != null) {
                          await _remindersCollection.doc(docId).update(newReminder);
                        }
                      } else {
                        await _remindersCollection.add(newReminder);
                        
                        try {
                          final dateTimeString = '${dateController.text} ${timeController.text}';
                          final scheduledTime = DateFormat('dd/MM/yyyy HH:mm').parse(dateTimeString);
                          
                          // Mostrar una notificación de prueba inmediata
                          await _notificationsService.showTestNotification(
                            titleController.text,
                            'Recordatorio guardado: ${timeController.text}',
                          );
                          
                          // Programar la notificación para la hora correcta
                          await _scheduleNotification(
                            titleController.text,
                            descriptionController.text,
                            scheduledTime,
                            notificationMinutesBefore,
                          );
                        } catch (e) {
                          print('Error al procesar notificación: $e');
                        }
                      }

                      setState(() {});
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, complete todos los campos.')),
                      );
                    }
                  },
                  child: Text(existingReminder != null ? 'Actualizar Recordatorio' : 'Guardar Recordatorio'),
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
        onPressed: () => _addOrEditReminder(),
        backgroundColor: const Color.fromARGB(255, 160, 19, 66),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 156, 39, 176),
        title: const Text(
          'Recordatorios',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _remindersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No hay recordatorios disponibles. Agrega uno nuevo usando el botón +.'),
            );
          }

          final reminders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index].data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(reminder['title'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reminder['description'] ?? ''),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 4),
                          Text(reminder['date']?.split(' ')[0] ?? ''),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(reminder['date']?.split(' ')[1] ?? ''),
                        ],
                      ),
                      if (reminder['location'] != null)
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Text(reminder['location'] ?? ''),
                          ],
                        ),
                      if (reminder['tag'] != null)
                        Chip(label: Text(reminder['tag'] ?? '')),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _addOrEditReminder(
                            existingReminder: Map<String, String>.from(reminder),
                            index: index,
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: const Text('¿Estás seguro de que deseas eliminar este recordatorio?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await _remindersCollection.doc(reminders[index].id).delete();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al eliminar el recordatorio: $e')),
                              );
                            }
                          }
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