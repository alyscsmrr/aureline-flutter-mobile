import 'package:flutter/foundation.dart';

class AccountStore extends ChangeNotifier {
  AccountStore._();
  static final AccountStore instance = AccountStore._();

  String? email;
  String? name;

  bool get signedIn => email != null;

  String? signIn(String value, String password) {
    final normalized = value.trim().toLowerCase();
    const accounts = {
      'isabella.reyes@example.com': ['Isabella Reyes', 'Aureline123!'],
      'maria@aureline.hotel': ['Maria Cruz', 'Aureline123!'],
      'alex@aureline.hotel': ['Alex Morgan', 'Aureline123!'],
    };
    final account = accounts[normalized];
    if (account == null || account[1] != password) {
      return 'The email or password is incorrect. Please try again.';
    }
    email = normalized;
    name = account[0];
    notifyListeners();
    return null;
  }

  String? createAccount(String firstName, String lastName, String value, String password) {
    if (firstName.trim().length < 2 || lastName.trim().length < 2) return 'Enter your first and last name.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) return 'Enter a valid email address.';
    if (password.length < 8) return 'Use at least 8 characters for your password.';
    email = value.trim().toLowerCase();
    name = '${firstName.trim()} ${lastName.trim()}';
    notifyListeners();
    return null;
  }

  void signOut() {
    email = null;
    name = null;
    notifyListeners();
  }
}
