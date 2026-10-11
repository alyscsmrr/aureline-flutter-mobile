import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../screens/home_screen.dart';
import '../screens/rooms_screen.dart';
import '../screens/experiences_screen.dart';
import '../screens/account_screen.dart';

class ManagementShell extends StatefulWidget {
  const ManagementShell({super.key});
  @override
  State<ManagementShell> createState() => _ManagementShellState();
}

class _ManagementShellState extends State<ManagementShell> {
  int selectedIndex = 0;
  final pages = const [
    HomeScreen(),
    RoomsScreen(),
    ExperiencesScreen(),
    AccountScreen()
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: cream,
        body: SafeArea(child: IndexedStack(index: selectedIndex, children: pages)),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: border))),
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
          child: Row(children: [
            _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'The hotel', index: 0, active: selectedIndex == 0, onTap: (i) => setState(() => selectedIndex = i)),
            _NavItem(icon: Icons.bed_outlined, selectedIcon: Icons.bed, label: 'Rooms', index: 1, active: selectedIndex == 1, onTap: (i) => setState(() => selectedIndex = i)),
            _NavItem(icon: Icons.spa_outlined, selectedIcon: Icons.spa, label: 'Experiences', index: 2, active: selectedIndex == 2, onTap: (i) => setState(() => selectedIndex = i)),
            _NavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Account', index: 3, active: selectedIndex == 3, onTap: (i) => setState(() => selectedIndex = i)),
          ]),
        ),
      );
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
