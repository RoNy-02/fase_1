import 'package:flutter/material.dart';
import 'event_screen.dart';
import 'note_screen.dart';
import 'reminder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'menu principal',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 160, 19, 66),
          title: const Text(
            'Bienvenido...',
            style: TextStyle(
              fontSize: 25,
              color: Color(0xffffffff),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16.0),
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildMenuItem(context, 'Notas', Icons.note, const NoteScreen()),
            _buildMenuItem(context, 'Eventos', Icons.event, const EventScreen()),
            _buildMenuItem(context, 'Recordatorios', Icons.alarm, const ReminderScreen()),
            _buildMenuItem(context, 'Configuración', Icons.settings, const Center(child: Text('Configuración'))),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Widget destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Color.fromARGB(255, 160, 19, 66)),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
