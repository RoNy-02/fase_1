class Note {
  final String title;
  final String content;
  final bool isPinned;

  Note({
    required this.title,
    required this.content,
    this.isPinned = false,
  });
}
