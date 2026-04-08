import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/providers/notification_provider.dart';
import '../helpers/providers/data_provider.dart';
import '../models/reminder.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final NotificationProvider _notificationsService =
      NotificationProvider();
  
  String? selectedDate;
  String? selectedTime;
  final TextEditingController descriptionController = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = 
            '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime =
            '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _scheduleNotification() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora')),
      );
      return;
    }

    if (descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una descripción')),
      );
      return;
    }

    final dateTimeString = '$selectedDate $selectedTime';
    print('Intentando programar: $dateTimeString');

    try {
      final DateTime scheduledDateTime =
          DateFormat('dd/MM/yyyy HH:mm').parse(dateTimeString);
      print('Fecha parseada: $scheduledDateTime');

      if (scheduledDateTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La hora debe ser futura')),
        );
        return;
      }

      final int notificationId =
          scheduledDateTime.millisecondsSinceEpoch.toInt();

      print('Programando notificación...');
      await _notificationsService.scheduleNotification(
        'Recordatorio',
        descriptionController.text,
        scheduledDateTime,
        0,
        notificationId,
      );

      print('Notificación programada');
      
      // Guardar el recordatorio en el servicio
      final reminder = Reminder(
        date: selectedDate!,
        time: selectedTime!,
        description: descriptionController.text,
      );
      ReminderProvider().addReminder(reminder);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notificación programada para $dateTimeString'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        selectedDate = null;
        selectedTime = null;
        descriptionController.clear();
      });
    } catch (e) {
      print(' Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 156, 39, 176),
        title: const Text(
          'Recordatorios',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // Campo de Descripción
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción de la notificación',
                hintText: 'Ingresa lo que deseas recordar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 30),
            
            // Selector de Fecha
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(selectedDate ?? 'Seleccionar Fecha'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: _selectDate,
              ),
            ),
            const SizedBox(height: 20),
            
            // Selector de Hora
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(selectedTime ?? 'Seleccionar Hora'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: _selectTime,
              ),
            ),
            const SizedBox(height: 40),
            
            // Botón Push
            ElevatedButton(
              onPressed: _scheduleNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 160, 19, 66),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Programar Notificación',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            
            // Info
            const SizedBox(height: 30),
            if (selectedDate != null && selectedTime != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Notificación programada para:\n$selectedDate a las $selectedTime',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
            ),
        ),
      ),
    );
  }
}