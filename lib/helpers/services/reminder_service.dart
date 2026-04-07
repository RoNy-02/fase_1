import '../../models/reminder.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  
  late List<Reminder> _reminders;

  ReminderService._internal() {
    _reminders = [];
  }

  factory ReminderService() {
    return _instance;
  }

  List<Reminder> get reminders => _reminders;

  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
  }

  void removeReminder(int index) {
    if (index >= 0 && index < _reminders.length) {
      _reminders.removeAt(index);
    }
  }

  void clearReminders() {
    _reminders.clear();
  }
}
