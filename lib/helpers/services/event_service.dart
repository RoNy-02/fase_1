import '../../models/event.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  
  late List<Event> _events;

  EventService._internal() {
    _events = [];
  }

  factory EventService() {
    return _instance;
  }

  List<Event> get events => _events;

  void addEvent(Event event) {
    _events.add(event);
  }

  void removeEvent(int index) {
    if (index >= 0 && index < _events.length) {
      _events.removeAt(index);
    }
  }

  void clearEvents() {
    _events.clear();
  }
}
