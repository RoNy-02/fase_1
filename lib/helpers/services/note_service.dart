import '../../models/note.dart';

class NoteService {
  static final NoteService _instance = NoteService._internal();
  
  late List<Note> _notes;

  NoteService._internal() {
    _notes = [];
  }

  factory NoteService() {
    return _instance;
  }

  List<Note> get notes => _notes;

  void addNote(Note note) {
    _notes.add(note);
  }

  void removeNote(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index);
    }
  }

  void clearNotes() {
    _notes.clear();
  }
}
