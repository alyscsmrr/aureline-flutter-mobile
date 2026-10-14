import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../services/account_store.dart';
import '../common/widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final first = TextEditingController();
  final last = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController(text: '+63 9');
  final address = TextEditingController();
  final passport = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool busy = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  String? registrationToken;

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    passport.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  String? validateFirstName(String value) {
    if (value.isEmpty) return null;
    if (value.length < 2) return 'Minimum 2 characters';
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) return 'Only letters, spaces, hyphens, and apostrophes';
    return null;
  }

  String? validateLastName(String value) {
    if (value.isEmpty) return null;
    if (value.length < 2) return 'Minimum 2 characters';
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) return 'Only letters, spaces, hyphens, and apostrophes';
    return null;
  }

  String? validateEmail(String value) {
    if (value.isEmpty) return null;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) return 'Invalid email format';
    if (value.length < 5) return 'Minimum 5 characters';
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return null;
    if (value.length < 8) return 'Minimum 8 characters';
    return null;
  }

  String? validatePhone(String value) {
    if (value.isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final phoneDigits = digits.startsWith('639') ? digits.substring(3) : digits;
    if (phoneDigits.length != 9) return 'Phone number must contain exactly 9 digits';
    return null;
  }

  String? validateAddress(String value) {
    if (value.isEmpty) return null;
    if (value.length < 10) return 'Minimum 10 characters';
    if (value.length > 200) return 'Maximum 200 characters';
    if (!RegExp(r"^[a-zA-Z0-9\s#\-']+$").hasMatch(value)) return 'Only letters, numbers, spaces, #, -, and apostrophes';
    return null;
  }

  String? validatePassport(String value) {
    if (value.isEmpty) return null;
    if (value.length < 5) return 'Minimum 5 characters';
    if (value.length > 20) return 'Maximum 20 characters';
    if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(value)) return 'Only letters and numbers';
    return null;
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[^a-zA-Z0-9]'))) strength++;
    return strength;
  }

  String _getStrengthLabel(int strength) {
    switch (strength) {
      case 0: return '';
      case 1: return 'Weak';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Strong';
      case 5: return 'Very Strong';
      default: return '';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0: return const Color(0xFFE0E0E0);
      case 1: return const Color(0xFFFF4D4D);
      case 2: return const Color(0xFFFF7A45);
      case 3: return const Color(0xFFFFC53D);
      case 4: return const Color(0xFF73D13D);
      case 5: return const Color(0xFF52C41A);
      default: return const Color(0xFFE0E0E0);
    }
  }

  Future<void> submit() async {
    final firstNameError = validateFirstName(first.text);
    final lastNameError = validateLastName(last.text);
    final emailError = validateEmail(email.text);
    final phoneError = validatePhone(phone.text);
    final addressError = validateAddress(address.text);
    final passportError = validatePassport(passport.text);
    final passwordError = validatePassword(password.text);

    if (firstNameError != null || lastNameError != null || emailError != null || 
        phoneError != null || addressError != null || passportError != null || passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          firstNameError ?? lastNameError ?? emailError ?? phoneError ?? 
          addressError ?? passportError ?? passwordError!
        )),
      );
      return;
    }

    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => busy = true);
    final error = await AccountStore.instance.sendSignupOtp(email.text.trim().toLowerCase());
    if (!mounted) return;
    setState(() => busy = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    _showOtpDialog();
  }

  void _showOtpDialog() {
    final otpController = TextEditingController();
    bool otpBusy = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Enter Verification Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('We sent a 6-digit code to your email.'),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '123456',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: otpBusy
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: otpBusy
                  ? null
                  : () async {
                      if (otpController.text.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a 6-digit code')),
                        );
                        return;
                      }

                      setDialogState(() => otpBusy = true);
                      final error = await AccountStore.instance.verifySignupOtp(
                        email.text.trim().toLowerCase(),
                        otpController.text,
                      );

                      if (!mounted) return;
                      setDialogState(() => otpBusy = false);

                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                        return;
                      }

                      registrationToken = error;
                      Navigator.pop(context);
                      _completeRegistration();
                    },
              child: Text(otpBusy ? 'Verifying...' : 'Verify'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeRegistration() async {
    setState(() => busy = true);
    final error = await AccountStore.instance.createAccount(
      first.text,
      last.text,
      email.text,
      password.text,
      registrationToken!,
      phone.text,
      address.text,
      passport.text,
    );
    if (!mounted) return;
    setState(() => busy = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.of(context).pushReplacementNamed('/hotel');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: cream,
    body: SafeArea(child: SingleChildScrollView(child: Padding(
      padding: const EdgeInsets.fromLTRB(25, 35, 25, 55),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), padding: EdgeInsets.zero),
        const SizedBox(height: 25),
        const Text('A PLACE TO CALL YOUR OWN', style: eyebrowStyle),
        const SizedBox(height: 18),
        const Text('Your stay starts here.', style: displayStyle),
        const SizedBox(height: 12),
        const Text('Create your guest account for easier reservations and a more personal welcome.', style: bodyStyle),
        const SizedBox(height: 28),
        Row(children: [
          Expanded(
            child: TextField(
              controller: first,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'First name',
                errorText: validateFirstName(first.text),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: last,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Last name',
                errorText: validateLastName(last.text),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Email address',
            hintText: 'you@example.com',
            errorText: validateEmail(email.text),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: phone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Phone number',
            hintText: '+63 9',
            errorText: validatePhone(phone.text),
          ),
          onChanged: (value) {
            // Handle phone number formatting
            if (value.isEmpty || value == '+63 9' || value == '+63') {
              phone.text = '+63 9';
            } else {
              final digits = value.replaceAll(RegExp(r'\D'), '');
              final phoneDigits = digits.startsWith('639') ? digits.substring(3) : digits;
              phone.text = '+63 9' + phoneDigits.substring(0, phoneDigits.length > 9 ? 9 : phoneDigits.length);
            }
            phone.selection = TextSelection.fromPosition(TextPosition(offset: phone.text.length));
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: address,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Address',
            hintText: 'Street address',
            errorText: validateAddress(address.text),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passport,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'ID / passport number',
            hintText: 'Example: P1234567 or UMID number',
            errorText: validatePassport(passport.text),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: password,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'At least 8 characters',
            errorText: validatePassword(password.text),
            suffixIcon: IconButton(
              icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => obscurePassword = !obscurePassword),
            ),
          ),
          onChanged: (value) {
            setState(() {}); // Trigger rebuild to update strength indicator
          },
        ),
        if (password.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _getStrengthColor(_calculatePasswordStrength(password.text)),
                  ),
                  width: MediaQuery.of(context).size.width * (_calculatePasswordStrength(password.text) / 5),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStrengthLabel(_calculatePasswordStrength(password.text)),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmPassword,
          obscureText: obscureConfirm,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Confirm password',
            hintText: 'Re-enter password',
            errorText: confirmPassword.text.isNotEmpty && confirmPassword.text != password.text
                ? 'Passwords do not match'
                : null,
            suffixIcon: IconButton(
              icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
            ),
          ),
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: busy ? null : submit,
            style: FilledButton.styleFrom(
              backgroundColor: forest,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(busy ? 'Creating account...' : 'Create guest account'),
          ),
        ),
      ]),
    ))),
  );
}
