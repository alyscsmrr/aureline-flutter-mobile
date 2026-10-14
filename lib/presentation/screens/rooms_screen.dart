import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../data/hotel_data.dart';
import '../../data/room_inclusions.dart';
import '../../theme/app_theme.dart';
import '../../services/account_store.dart';
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
                child: _RoomCard(
                  index: index,
                  selected: selectedIndex == index,
                  onSelect: () => setState(() => selectedIndex = index),
                  onDetails: () => _showRoomDetails(index),
                ),
              ))),
            ),
          ),
          if (selectedIndex != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: FilledButton.icon(
                  onPressed: () => _continueWithRoom(),
                  icon: const Icon(Icons.arrow_forward, size: 17),
                  label: Text('Continue with ${rooms[selectedIndex!][0]}'),
                  style: FilledButton.styleFrom(backgroundColor: forest, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
                ),
              ),
            ),
        ],
      );

  void _continueWithRoom() {
    if (AccountStore.instance.signedIn) {
      // Navigate to booking screen with this room pre-selected
      Navigator.pushNamed(context, '/hotel/booking');
    } else {
      // Navigate to sign-in
      Navigator.pushNamed(context, '/sign-in');
    }
  }

  void _showRoomDetails(int index) {
    final room = rooms[index];
    final roomData = <String, dynamic>{
      'name': room[0] as String,
      'description': room[1] as String,
      'size': room[2] as String,
      'image': roomImages[index] as String,
      'index': index,
    };

    // Determine room type based on index
    String roomType;
    if (index == 0) {
      roomType = 'Single';
    } else if (index == 1) {
      roomType = 'Double';
    } else if (index == 2) {
      roomType = 'Deluxe';
    } else {
      roomType = 'Suite';
    }

    final inclusions = roomInclusions[roomType] ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(roomData['name']!),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      roomData['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: paleGreen,
                          child: const Icon(Icons.bed, size: 48, color: muted),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  roomData['description']!,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: muted),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.square_foot, size: 16, color: sage),
                    const SizedBox(width: 8),
                    Text(
                      roomData['size']!,
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.king_bed, size: 16, color: sage),
                    const SizedBox(width: 8),
                    const Text(
                      'King bed',
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Room amenities', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink)),
                const SizedBox(height: 12),
                ...inclusions.map((inclusion) => _AmenityItem(inclusion)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selectedIndex = index);
            },
            style: FilledButton.styleFrom(backgroundColor: forest, foregroundColor: Colors.white),
            child: const Text('Select this room'),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final int index;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onDetails;
  const _RoomCard({required this.index, required this.selected, required this.onSelect, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    final room = rooms[index];
    return InkWell(
      onTap: onDetails,
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
            Row(children: [const Icon(Icons.square_foot, size: 15, color: sage), const SizedBox(width: 5), Text(room[2], style: const TextStyle(color: muted, fontSize: 10)), const Spacer(), Text(selected ? 'Selected' : 'Tap to view details', style: TextStyle(color: selected ? forest : sage, fontSize: 11, fontWeight: FontWeight.w600))]),
          ])),
        ]),
      ),
    );
  }
}

class _AmenityItem extends StatelessWidget {
  final String text;
  const _AmenityItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 14, color: forest),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: muted)),
        ],
      ),
    );
  }
}
