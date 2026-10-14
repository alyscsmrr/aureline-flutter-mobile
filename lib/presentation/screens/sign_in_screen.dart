import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../data/hotel_data.dart';
import '../../theme/app_theme.dart';
import '../../services/account_store.dart';
import '../common/widgets.dart';

class SignInScreen extends StatefulWidget {
  final bool embedded;
  const SignInScreen({super.key, this.embedded = false});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  bool obscure = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      showAppMessage(context, 'Enter your email and password.');
      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email.text.trim())) {
      showAppMessage(context, 'Enter a valid email address.');
      return;
    }

    if (password.text.length < 8) {
      showAppMessage(context, 'Password must be at least 8 characters.');
      return;
    }

    setState(() => busy = true);
    final error = await AccountStore.instance.signIn(email.text.trim(), password.text);
    if (!mounted) return;
    setState(() => busy = false);

    if (error != null) {
      if (error == 'OTP_REQUIRED') {
        // Send OTP before showing dialog
        setState(() => busy = true);
        final normalizedEmail = email.text.trim().toLowerCase();
        final otpError = await AccountStore.instance.sendLoginOtp(normalizedEmail);
        setState(() => busy = false);
        
        if (otpError != null) {
          showAppMessage(context, otpError);
          return;
        }
        
        _showOtpDialog();
      } else {
        showAppMessage(context, error);
      }
      return;
    }

    Navigator.of(context).pushReplacementNamed('/hotel');
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
                        showAppMessage(context, 'Enter a 6-digit code.');
                        return;
                      }

                      setDialogState(() => otpBusy = true);
                      final error = await AccountStore.instance.verifyLoginOtp(
                        email.text.trim().toLowerCase(),
                        otpController.text,
                      );

                      if (!mounted) return;
                      setDialogState(() => otpBusy = false);

                      if (error != null) {
                        showAppMessage(context, error);
                        return;
                      }

                      Navigator.pop(context);
                      Navigator.of(context).pushReplacementNamed('/hotel');
                    },
              child: Text(otpBusy ? 'Verifying...' : 'Verify'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: cream,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _AuthPhoto(),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 48),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (!widget.embedded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: TextButton.icon(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back, size: 15),
                        label: const Text('Back to the hotel'),
                        style: TextButton.styleFrom(foregroundColor: muted, padding: EdgeInsets.zero),
                      ),
                    ),
                  const Text('WELCOME TO AURELINE HOTEL', style: eyebrowStyle),
                  const SizedBox(height: 18),
                  Text('Good to see you again.', style: GoogleFonts.playfairDisplay(color: ink, fontSize: 32, height: 1.15)),
                  const SizedBox(height: 12),
                  const Text('Sign in to your account. Your next chapter awaits.', style: bodyStyle),
                  const SizedBox(height: 28),
                  TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', hintText: 'you@example.com')),
                  const SizedBox(height: 16),
                  TextField(controller: password, obscureText: obscure, decoration: InputDecoration(labelText: 'Password', hintText: 'Enter your password', suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => obscure = !obscure)))),
                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => showAppMessage(context, 'Password reset is available from the web account flow.'), child: const Text('Forgot password?'))),
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, child: FilledButton(onPressed: busy ? null : submit, style: FilledButton.styleFrom(backgroundColor: forest, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(busy ? 'Signing in...' : 'Sign in'))),
                  const SizedBox(height: 18),
                  Center(child: TextButton(onPressed: () => Navigator.pushNamed(context, '/sign-up'), child: const Text('First time here? Create a guest account'))),
                ]),
              ),
            ]),
          ),
        ),
      );
}

class _AuthPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 292,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(heroImage, fit: BoxFit.cover),
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x220F221A), Color(0xE613241D)]))),
          const Positioned(top: 24, left: 28, child: Brand(light: true)),
          Positioned(left: 28, right: 28, bottom: 25, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AURELINE HOTEL - SORSOGON CITY', style: TextStyle(color: Color(0xFFD4DCC8), fontSize: 8, letterSpacing: 1.8)),
            const SizedBox(height: 12),
            Text('Some places\nstay with you.', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 34, height: 1.08)),
            const SizedBox(height: 12),
            const Text('A beautiful room in Sorsogon City.\nA welcome that feels like coming home.', style: TextStyle(color: Color(0xFFE2E7DC), fontSize: 11, height: 1.7)),
          ])),
        ]),
      );
}
