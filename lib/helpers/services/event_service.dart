import 'package:flutter/foundation.dart';
import '../../models/event.dart';

class EventService extends ChangeNotifier {
  static final EventService _instance = EventService._internal();
  
  List<Event> _events = [];

  EventService._internal();

  factory EventService() {
    return _instance;
  }

  List<Event> get events => _events;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void removeEvent(int index) {
    if (index >= 0 && index < _events.length) {
      _events.removeAt(index);
      notifyListeners();
    }
  }

  void clearEvents() {
    _events.clear();
    notifyListeners();
  }
}
