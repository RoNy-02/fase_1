bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
  return emailRegex.hasMatch(email);
}

bool isValidPassword(String password) {
  return password.length >= 6;
}