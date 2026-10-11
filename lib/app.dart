import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'presentation/shell/management_shell.dart';
import 'presentation/screens/sign_in_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/contact_screen.dart';

class AurelineApp extends StatelessWidget {
  const AurelineApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aureline Hotel',
      theme: AppTheme.light,
      routes: {
        '/hotel': (_) => const ManagementShell(),
        '/sign-in': (_) => const SignInScreen(),
        '/sign-up': (_) => const SignUpScreen(),
        '/contact': (_) => const ContactScreen(),
      },
      home: const ManagementShell());
}
