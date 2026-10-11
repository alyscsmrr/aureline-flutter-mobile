import 'package:flutter/material.dart';
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
  final password = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    first.dispose(); last.dispose(); email.dispose(); password.dispose(); super.dispose();
  }

  Future<void> submit() async {
    setState(() => busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final error = AccountStore.instance.createAccount(first.text, last.text, email.text, password.text);
    if (!mounted) return;
    setState(() => busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
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
        Row(children: [Expanded(child: TextField(controller: first, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'First name'))), const SizedBox(width: 12), Expanded(child: TextField(controller: last, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Last name')))]),
        const SizedBox(height: 16),
        TextField(controller: email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Email address', hintText: 'you@example.com')),
        const SizedBox(height: 16),
        TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', hintText: 'At least 8 characters')),
        const SizedBox(height: 25),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: busy ? null : submit, style: FilledButton.styleFrom(backgroundColor: forest, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(busy ? 'Creating account...' : 'Create guest account'))),
      ]),
    ))),
  );
}
