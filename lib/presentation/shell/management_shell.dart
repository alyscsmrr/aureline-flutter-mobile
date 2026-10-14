import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/account_store.dart';
import '../screens/home_screen.dart';
import '../screens/rooms_screen.dart';
import '../screens/experiences_screen.dart';
import '../screens/account_screen.dart';
import '../screens/guest_stays_screen.dart';
import '../screens/guest_booking_search_screen.dart';

class ManagementShell extends StatefulWidget {
  const ManagementShell({super.key, this.initialIndex = 0});
  final int initialIndex;
  @override
  State<ManagementShell> createState() => _ManagementShellState();
}

class _ManagementShellState extends State<ManagementShell> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(ManagementShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedIndex >= pages.length) {
      setState(() => selectedIndex = 0);
    }
  }

  List<Widget> get pages {
    final isGuest = AccountStore.instance.signedIn;
    if (isGuest) {
      return const [
        GuestStaysScreen(),
        GuestBookingSearchScreen(),
        AccountScreen()
      ];
    }
    return const [
      HomeScreen(),
      RoomsScreen(),
      ExperiencesScreen(),
      AccountScreen()
    ];
  }

  List<_NavItemData> get navItems {
    final isGuest = AccountStore.instance.signedIn;
    if (isGuest) {
      return const [
        _NavItemData(icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month, label: 'My stays'),
        _NavItemData(icon: Icons.search_outlined, selectedIcon: Icons.search, label: 'Book'),
        _NavItemData(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Account'),
      ];
    }
    return const [
      _NavItemData(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'The hotel'),
      _NavItemData(icon: Icons.bed_outlined, selectedIcon: Icons.bed, label: 'Rooms'),
      _NavItemData(icon: Icons.spa_outlined, selectedIcon: Icons.spa, label: 'Experiences'),
      _NavItemData(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Account'),
    ];
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: AccountStore.instance,
        builder: (context, _) {
          final currentPages = pages;
          final safeIndex = selectedIndex.clamp(0, currentPages.length - 1);
          if (safeIndex != selectedIndex) {
            // Schedule the state update after the current build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => selectedIndex = safeIndex);
            });
          }
          return Scaffold(
            backgroundColor: cream,
            body: SafeArea(child: IndexedStack(index: safeIndex, children: currentPages)),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: border))),
              padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
              child: Row(children: [
                for (int i = 0; i < navItems.length; i++)
                  _NavItem(
                    icon: navItems[i].icon,
                    selectedIcon: navItems[i].selectedIcon,
                    label: navItems[i].label,
                    index: i,
                    active: safeIndex == i,
                    onTap: (idx) => setState(() => selectedIndex = idx),
                  ),
              ]),
            ),
          );
        },
      );
}

class _NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final IconData icon, selectedIcon;
  final String label;
  final int index;
  final bool active;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.selectedIcon, required this.label, required this.index, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(active ? selectedIcon : icon, color: active ? forest : muted, size: 20),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(color: active ? forest : muted, fontSize: 9, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
            ]),
          ),
        ),
      );
}
