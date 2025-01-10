// validator.dart

bool validateEmail(String email) {
  // Basic email validation
  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegExp.hasMatch(email);
}

bool validatePassword(String password) {
  // Password validation for at least 8 characters with letters and numbers
  final RegExp passwordRegExp = RegExp(
    r'^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$',
  );
  return passwordRegExp.hasMatch(password);
}
