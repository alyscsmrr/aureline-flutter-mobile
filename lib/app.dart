import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'presentation/shell/management_shell.dart';
import 'presentation/screens/sign_in_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/contact_screen.dart';
import 'presentation/screens/guest_stays_screen.dart';
import 'presentation/screens/account_screen.dart';
import 'presentation/screens/guest_booking_search_screen.dart';
import 'presentation/screens/guest_room_details_screen.dart';

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
        '/guest-stays': (_) => const GuestStaysScreen(),
        '/account': (_) => const AccountScreen(),
        '/hotel/booking': (_) => const ManagementShell(initialIndex: 1),
        '/hotel/rooms': (_) => const ManagementShell(initialIndex: 1),
        '/guest-room-details': (_) => const GuestRoomDetailsScreen(),
      },
      home: const ManagementShell());
}
