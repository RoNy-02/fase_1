import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(date);
}

String formatTime(DateTime date) {
  final DateFormat formatter = DateFormat('hh:mm a');
  return formatter.format(date);
}