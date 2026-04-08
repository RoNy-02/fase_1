import 'package:fase_1/Screens/events_screen.dart';
import 'package:fase_1/Screens/notes_screen.dart';
import 'package:fase_1/Screens/reminder_screen.dart';
import 'package:flutter/material.dart';
import '../helpers/providers/notification_provider.dart';
import '../helpers/providers/data_provider.dart';
import '../helpers/providers/auth_provider.dart';
import '../models/note.dart';
import '../models/event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirestoreProvider _firestoreProvider = FirestoreProvider();
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Sincronizar datos de Firebase al iniciar la pantalla
    _loadDataFromFirebase();
  }

  Future<void> _loadDataFromFirebase() async {
    if (!_isDataLoaded) {
      print('📱 HomeScreen iniciada - cargando datos de Firebase...');
      await _firestoreProvider.syncAllUserData();
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  static List<Widget> _pages = <Widget>[
    HomeMenu(), // Nueva pantalla de inicio con datos y botones
    NotesScreen(),
    EventsScreen(),
    ReminderScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Color(0xffffffff),
        fontSize: 23),
        title: const Text('Notas y más..'),
        backgroundColor: const Color.fromARGB(255, 160, 19, 66),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Deseas cerrar sesión? Tus datos serán conservados.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await AuthProvider.signOut();
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            // AuthWrapper detectará automáticamente el logout
                            // y mostrará LoginRegisterScreen
                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ Error: $e'),
                                duration: const Duration(seconds: 3),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Cerrar Sesión'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 160, 19, 66),
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Recordatorios',
          ),
        ],
      ),
    );
  }
}

class HomeMenu extends StatefulWidget {
  @override
  State<HomeMenu> createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  final NotificationProvider _notificationsService =
      NotificationProvider();
  bool _isTestingNotification = false;

  Future<void> _sendTestNotification() async {
    setState(() => _isTestingNotification = true);
    
    try {
      await _notificationsService.showTestNotification(
        '🧪 Notificación de Prueba',
        'Si ves este mensaje, ¡las notificaciones funcionan! ✅',
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notificación enviada. Revisa tu teléfono.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isTestingNotification = false);
    }
  }

  final TextEditingController _quickNoteController = TextEditingController();

  @override
  void dispose() {
    _quickNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bienvenido..😉',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 39, 176, 174),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          // Cuadro de nota rápida centrado
          Card(
            elevation: 4,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Crear Nota Rápida',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 39, 176, 174),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: _quickNoteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu nota aquí...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_quickNoteController.text.isNotEmpty) {
                        final firestoreProvider = FirestoreProvider();
                        
                        await firestoreProvider.addNote({
                          'title': 'Nota Rápida',
                          'content': _quickNoteController.text,
                          'isPinned': false,
                        });
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Nota guardada correctamente'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _quickNoteController.clear();
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Nota'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 39, 176, 174),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          Expanded(
            child: ListView(
              children: [
                _DataCard(
                  title: 'Notas',
                  description: 'Tus notas más recientes',
                  icon: Icons.note,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotesScreen(),
                      ),
                    );
                  },
                ),
                _DataCard(
                  title: 'Eventos',
                  description: 'Próximos eventos en tu agenda',
                  icon: Icons.event,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventsScreen(),
                      ),
                    );
                  },
                ),
                _DataCard(
                  title: 'Recordatorios',
                  description: 'Tus recordatorios pendientes',
                  icon: Icons.alarm,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReminderScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24.0),
                // Sección de Recordatorios Creados
                _RemindersSection(),
                const SizedBox(height: 24.0),
                // Sección de Eventos Creados
                _EventsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DataCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemindersSection extends StatefulWidget {
  @override
  State<_RemindersSection> createState() => _RemindersSectionState();
}

class _RemindersSectionState extends State<_RemindersSection> {
  @override
  Widget build(BuildContext context) {
    final reminders = ReminderProvider().reminders;

    if (reminders.isEmpty) {
      return Card(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.alarm, color: Colors.grey, size: 40),
              const SizedBox(height: 8.0),
              const Text(
                'Recordatorios Creados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'No hay recordatorios creados aún',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.alarm, color: Colors.green, size: 28),
                const SizedBox(width: 12.0),
                const Text(
                  'Recordatorios Creados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Text(
                  '${reminders.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            ...reminders.asMap().entries.map((entry) {
              int index = entry.key;
              final reminder = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${reminder.date} ${reminder.time}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              reminder.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            ReminderProvider().removeReminder(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Recordatorio eliminado'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _EventsSection extends StatefulWidget {
  @override
  State<_EventsSection> createState() => _EventsSectionState();
}

class _EventsSectionState extends State<_EventsSection> {
  late EventProvider _eventService;

  @override
  void initState() {
    super.initState();
    _eventService = EventProvider();
    print('📌 EventsSection creada, eventos actuales: ${_eventService.events.length}');
    _eventService.addListener(_onEventsChanged);
  }

  @override
  void dispose() {
    _eventService.removeListener(_onEventsChanged);
    super.dispose();
  }

  void _onEventsChanged() {
    print('📌 EventsSection: cambio detectado, eventos ahora: ${_eventService.events.length}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final events = _eventService.events;

    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: Colors.blue, size: 28),
                const SizedBox(width: 12.0),
                const Text(
                  'Eventos Creados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                Text(
                  '${events.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            ...events.asMap().entries.map((entry) {
              int index = entry.key;
              final event = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              '${event.date} ${event.time}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              event.location,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              event.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _eventService.removeEvent(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Evento eliminado'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
