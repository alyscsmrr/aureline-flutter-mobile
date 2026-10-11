import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../common/widgets.dart';
import '../../services/account_store.dart';
import 'sign_in_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AccountStore.instance.signedIn) return const SignInScreen(embedded: true);
    return AnimatedBuilder(
      animation: AccountStore.instance,
      builder: (context, _) => CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: PublicHeader()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 50, 25, 50),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('YOUR AURELINE STAY', style: eyebrowStyle),
              const SizedBox(height: 18),
              const Text('Everything in one place.', style: displayStyle),
              const SizedBox(height: 16),
              const Text(
                  'Sign in to view your reservations, manage your profile, and keep your stay details close.',
                  style: bodyStyle),
              const SizedBox(height: 28),
              if (AccountStore.instance.signedIn) ...[
                Text('Signed in as ${AccountStore.instance.name}', style: bodyStyle),
                const SizedBox(height: 20),
                FilledButton(onPressed: AccountStore.instance.signOut, style: FilledButton.styleFrom(backgroundColor: forest, foregroundColor: Colors.white), child: const Text('Sign out')),
              ] else ...[
              FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/sign-in'),
                  style: FilledButton.styleFrom(
                      backgroundColor: forest, foregroundColor: Colors.white),
                  child: const Text('Sign in')),
              const SizedBox(height: 12),
                OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/sign-up'),
                    child: const Text('Create an account')),
              ],
            ]),
          ),
        ),
      ],
    ));
  }
}
