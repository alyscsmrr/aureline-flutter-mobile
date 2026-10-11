import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/hotel_data.dart';
import '../../theme/app_theme.dart';
import '../common/widgets.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});
  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: PublicHeader()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 30, 25, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('THE AURELINE COLLECTION', style: eyebrowStyle),
                SizedBox(height: 18),
                Text('Rooms & suites', style: displayStyle),
                SizedBox(height: 10),
                Text('Four ways to settle in. One feeling of being right where you belong.', style: bodyStyle),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(children: List.generate(rooms.length, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SelectableRoomCard(
                  index: index,
                  selected: selectedIndex == index,
                  onSelect: () => setState(() => selectedIndex = index),
                ),
              ))),
            ),
          ),
          if (selectedIndex != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: FilledButton.icon(
                  onPressed: () => showAppMessage(context, '${rooms[selectedIndex!][0]} selected. Choose your dates to continue.'),
                  icon: const Icon(Icons.arrow_forward, size: 17),
                  label: Text('Continue with ${rooms[selectedIndex!][0]}'),
                  style: FilledButton.styleFrom(backgroundColor: forest, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
                ),
              ),
            ),
        ],
      );
}

class _SelectableRoomCard extends StatelessWidget {
  final int index;
  final bool selected;
  final VoidCallback onSelect;
  const _SelectableRoomCard({required this.index, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final room = rooms[index];
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF1F3E9) : Colors.white,
          border: Border.all(color: selected ? forest : border, width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(7),
          boxShadow: selected ? const [BoxShadow(color: Color(0x18314F3F), blurRadius: 14, offset: Offset(0, 6))] : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            SizedBox(height: 220, width: double.infinity, child: Image.network(roomImages[index], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: paleGreen))),
            if (selected)
              Positioned(top: 14, right: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: forest, borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check, color: Colors.white, size: 14), SizedBox(width: 5), Text('Selected', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))]))),
          ]),
          Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(room[0], style: const TextStyle(color: ink, fontFamily: 'Georgia', fontSize: 22)),
            const SizedBox(height: 8),
            Text(room[1], style: bodyStyle),
            const SizedBox(height: 14),
            Row(children: [const Icon(Icons.square_foot, size: 15, color: sage), const SizedBox(width: 5), Text(room[2], style: const TextStyle(color: muted, fontSize: 10)), const Spacer(), Text(selected ? 'Selected' : 'Tap to select', style: TextStyle(color: selected ? forest : sage, fontSize: 11, fontWeight: FontWeight.w600))]),
          ])),
        ]),
      ),
    );
  }
}
