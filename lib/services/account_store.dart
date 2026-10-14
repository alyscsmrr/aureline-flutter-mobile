import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class AccountStore extends ChangeNotifier {
  AccountStore._();
  static final AccountStore instance = AccountStore._();

  String? email;
  String? name;
  String? token;
  String? guestId;
  String? _pendingRegistrationToken;

  bool get signedIn => email != null && token != null;

  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'auth_email';
  static const String _nameKey = 'auth_name';
  static const String _guestIdKey = 'auth_guest_id';

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
    email = prefs.getString(_emailKey);
    name = prefs.getString(_nameKey);
    guestId = prefs.getString(_guestIdKey);
    
    // Validate session by calling profile endpoint
    if (token != null) {
      try {
        final profile = await AuthService.getProfile(token!);
        // Check if the account still exists and is a guest
        if (profile == null || profile['role'] != 'Guest') {
          // Invalid session or not a guest account
          await _clearStorage();
          email = null;
          name = null;
          token = null;
          guestId = null;
        }
      } catch (e) {
        // Session is invalid
        await _clearStorage();
        email = null;
        name = null;
        token = null;
        guestId = null;
      }
    }
    
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token!);
    } else {
      await prefs.remove(_tokenKey);
    }
    if (email != null) {
      await prefs.setString(_emailKey, email!);
    } else {
      await prefs.remove(_emailKey);
    }
    if (name != null) {
      await prefs.setString(_nameKey, name!);
    } else {
      await prefs.remove(_nameKey);
    }
    if (guestId != null) {
      await prefs.setString(_guestIdKey, guestId!);
    } else {
      await prefs.remove(_guestIdKey);
    }
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_guestIdKey);
  }

  Future<String?> signIn(String value, String password) async {
    final normalized = value.trim().toLowerCase();
    try {
      final response = await AuthService.login(normalized, password);

      if (response.containsKey('requiresOtp') && response['requiresOtp'] == true) {
        return 'OTP_REQUIRED';
      }

      final user = response['user'] as Map<String, dynamic>;
      if (user['role'] != 'Guest') {
        return 'No guest account found';
      }

      email = normalized;
      name = user['name'] as String;
      token = response['token'] as String;
      guestId = user['guestId'] as String?;

      await _saveToStorage();
      notifyListeners();
      return null;
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      // Check if it's specifically an incorrect password error
      if (errorMessage.contains('incorrect') || errorMessage.contains('password')) {
        return 'Incorrect email/password';
      }
      // For other errors (email not found, etc.), show generic message
      return 'No guest account found';
    }
  }

  Future<String?> verifyLoginOtp(String email, String otp) async {
    try {
      final response = await AuthService.verifyOtp(email, otp);
      final user = response['user'] as Map<String, dynamic>;
      if (user['role'] != 'Guest') {
        return 'No guest account found';
      }

      this.email = email;
      name = user['name'] as String;
      token = response['token'] as String;
      guestId = user['guestId'] as String?;

      await _saveToStorage();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> sendLoginOtp(String email) async {
    try {
      await AuthService.sendOtp(email, 'Login Verification');
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  String? validateSignup(String firstName, String lastName, String value, String password) {
    if (firstName.trim().length < 2 || lastName.trim().length < 2) {
      return 'Enter your first and last name.';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    if (password.length < 8) {
      return 'Use at least 8 characters for your password.';
    }
    return null;
  }

  Future<String?> sendSignupOtp(String email) async {
    try {
      await AuthService.sendOtp(email, 'Account Creation');
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> verifySignupOtp(String email, String otp) async {
    try {
      final response = await AuthService.verifyOtp(email, otp);
      if (response.containsKey('registrationToken')) {
        _pendingRegistrationToken = response['registrationToken'] as String;
        return null; // null = success
      }
      return 'OTP verification failed';
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> sendOtp(String email, String purpose) async {
    try {
      await AuthService.sendOtp(email, purpose);
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    try {
      await AuthService.verifyOtp(email, otp);
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> createAccount(
    String firstName,
    String lastName,
    String value,
    String password,
    String registrationToken,
    String phone,
    String address,
    String passport,
  ) async {
    final normalized = value.trim().toLowerCase();
    final regToken = registrationToken.isNotEmpty ? registrationToken : (_pendingRegistrationToken ?? '');
    try {
      final response = await AuthService.register(
        {
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': normalized,
          'phone': phone,
          'address': address,
          'passport': passport,
        },
        password,
        regToken,
      );

      final user = response['user'] as Map<String, dynamic>;
      email = normalized;
      name = user['name'] as String;
      token = response['token'] as String;
      guestId = user['guestId'] as String?;
      _pendingRegistrationToken = null;

      await _saveToStorage();
      notifyListeners();
      return null;
    } catch (e) {
      _pendingRegistrationToken = null;
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      // Check if it's an email already taken error
      if (errorMessage.contains('already registered') && errorMessage.contains('Email')) {
        return 'Email address already taken';
      }
      // Check if it's a phone number already taken error
      if (errorMessage.contains('already registered') && errorMessage.contains('Phone')) {
        return 'Phone number already taken';
      }
      return errorMessage;
    }
  }

  Future<void> signOut() async {
    email = null;
    name = null;
    token = null;
    guestId = null;
    await _clearStorage();
    notifyListeners();
  }

  Future<void> initialize() async {
    await _loadFromStorage();
  }
}
