import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../data/hotel_data.dart';
import '../../data/room_inclusions.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/account_store.dart';
import '../common/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? checkIn;
  DateTime? checkOut;
  int guests = 2;
  List<Map<String, dynamic>> availableRooms = [];
  bool searching = false;
  String? searchError;

  @override
  void initState() {
    super.initState();
    // Set default dates to today and tomorrow
    final today = DateTime.now();
    checkIn = today;
    checkOut = today.add(const Duration(days: 1));
  }

  DateTime get today => DateTime.now();
  DateTime get minCheckOut => checkIn != null ? checkIn!.add(const Duration(days: 1)) : today;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool get canSearch => checkIn != null && checkOut != null && checkOut!.isAfter(checkIn!);

  Future<void> _searchRooms() async {
    if (!canSearch) {
      showAppMessage(context, 'Please select check-in and check-out dates first');
      setState(() => searchError = 'Choose valid future dates with check-out after check-in.');
      return;
    }

    setState(() => searching = true);
    searchError = null;

    try {
      final rooms = await AuthService.searchRooms(
        checkIn: _formatDate(checkIn),
        checkOut: _formatDate(checkOut),
        guests: guests,
        token: AccountStore.instance.token,
      );

      if (rooms is List) {
        final convertedRooms = rooms.map((room) {
          if (room is Map<String, dynamic>) {
            return room;
          } else {
            return Map<String, dynamic>.from(room as Map);
          }
        }).toList();
        setState(() => availableRooms = convertedRooms);
      } else {
        setState(() => searchError = 'Invalid response from server');
      }
    } catch (e) {
      setState(() => searchError = e.toString().replaceAll('Exception: ', ''));
      showAppMessage(context, 'Search failed: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      setState(() => searching = false);
    }
  }

  void _selectRoom(Map<String, dynamic> room) {
    if (AccountStore.instance.signedIn) {
      // Navigate to guest booking with this room pre-selected
      Navigator.pushNamed(
        context,
        '/guest-room-details',
        arguments: {
          'room': room,
          'checkIn': _formatDate(checkIn),
          'checkOut': _formatDate(checkOut),
          'guests': guests,
        },
      );
    } else {
      Navigator.pushNamed(context, '/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: PublicHeader()),
        SliverToBoxAdapter(child: _hero(context)),
        SliverToBoxAdapter(child: _bookingBar(context)),
        if (availableRooms.isNotEmpty || searchError != null) _RoomResults(),
        SliverToBoxAdapter(child: _intro()),
        SliverToBoxAdapter(child: _amenities()),
        SliverToBoxAdapter(child: _offers()),
        SliverToBoxAdapter(child: _collection(context)),
        SliverToBoxAdapter(child: _experienceFeature()),
        SliverToBoxAdapter(child: _experiences()),
        SliverToBoxAdapter(child: _invitation(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 24))
      ]);

  Widget _hero(BuildContext context) => Container(
      height: 480,
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 52),
      decoration: BoxDecoration(
          image: const DecorationImage(
              image: NetworkImage(heroImage),
              fit: BoxFit.cover,
              colorFilter:
                  ColorFilter.mode(Color(0xAA132720), BlendMode.darken))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('—  AURELINE HOTEL',
                style: TextStyle(
                    color: Color(0xFFE0E3CF), fontSize: 9, letterSpacing: 1.9)),
            const SizedBox(height: 22),
            const Text('Aureline Hotel',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Georgia', fontSize: 43)),
            const SizedBox(height: 12),
            const Text(
                'Find a softer rhythm near the heart of Sorsogon.\nStay longer and enjoy exclusive room offers.',
                style: TextStyle(
                    color: Color(0xFFE2E7DC), fontSize: 11, height: 1.8)),
            const SizedBox(height: 18),
            TextButton.icon(
                onPressed: () => showAppMessage(context, 'Browse rooms below.'),
                icon: const Icon(Icons.arrow_upward, size: 15),
                label: const Text('Discover Aureline'),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white, padding: EdgeInsets.zero))
          ]));

  Widget _bookingBar(BuildContext context) => Transform.translate(
        offset: const Offset(0, -28),
        child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: const Color(0xFFFFFEFB),
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x14253C33),
                      blurRadius: 20,
                      offset: Offset(0, 8))
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('YOUR NEXT CHAPTER',
                  style:
                      TextStyle(color: sage, fontSize: 8, letterSpacing: 1.4)),
              const SizedBox(height: 5),
              const Text('Stay a little.',
                  style: TextStyle(
                      color: ink, fontFamily: 'Georgia', fontSize: 24)),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: _dateField('Check-in', checkIn, () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: today,
                    firstDate: today,
                    lastDate: today.add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      checkIn = picked;
                      if (checkOut != null && checkOut!.isBefore(picked)) {
                        checkOut = picked.add(const Duration(days: 1));
                      }
                    });
                  }
                })),
                const SizedBox(width: 10),
                Expanded(child: _dateField('Check-out', checkOut, () async {
                  if (checkIn == null) {
                    showAppMessage(context, 'Select check-in date first');
                    return;
                  }
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: minCheckOut,
                    firstDate: minCheckOut,
                    lastDate: today.add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => checkOut = picked);
                  }
                }, enabled: checkIn != null))
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _guestField()),
                const SizedBox(width: 10),
                FilledButton(
                    onPressed: searching ? null : _searchRooms,
                    style: FilledButton.styleFrom(
                        backgroundColor: forest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15)),
                    child: searching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Find your room',
                            style: TextStyle(fontSize: 10)))
              ])
            ])),
      );

  Widget _dateField(String label, DateTime? date, VoidCallback onTap, {bool enabled = true}) => InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: enabled ? border : muted.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(3),
            color: enabled ? null : muted.withOpacity(0.1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: sage, fontSize: 8)),
            const SizedBox(height: 5),
            Text(
              date != null ? _formatDate(date) : 'Select date',
              style: TextStyle(
                color: enabled ? ink : muted,
                fontSize: 11,
              ),
            ),
          ]),
        ),
      );

  Widget _guestField() => Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Guests', style: TextStyle(color: sage, fontSize: 8)),
          const SizedBox(height: 5),
          Row(
            children: [
              IconButton(
                onPressed: guests > 1 ? () => setState(() => guests--) : null,
                icon: const Icon(Icons.remove, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  minimumSize: const Size(24, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Text('$guests', style: const TextStyle(color: ink, fontSize: 11)),
              const SizedBox(width: 8),
              IconButton(
                onPressed: guests < 10 ? () => setState(() => guests++) : null,
                icon: const Icon(Icons.add, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  minimumSize: const Size(24, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ]),
      );

  Widget _RoomResults() => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 40, 25, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AVAILABLE ROOMS', style: eyebrowStyle),
            const SizedBox(height: 18),
            const Text('Your perfect match.', style: sectionStyle),
            const SizedBox(height: 20),
            if (searchError != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Text(
                  searchError!,
                  style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
                ),
              )
            else
              ...availableRooms.map((room) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AvailableRoomCard(
                  room: room,
                  onTap: () => _selectRoom(room),
                ),
              )),
          ]),
        ),
      );
  Widget _intro() => const Padding(
      padding: EdgeInsets.fromLTRB(25, 70, 25, 58),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('WELCOME TO AURELINE HOTEL', style: eyebrowStyle),
        SizedBox(height: 18),
        Text('A calmer side of Sorsogon.\nA place to feel.',
            style: displayStyle),
        SizedBox(height: 22),
        Text(
            'There is a certain kind of comfort in the things done well. Soft linen. Warm light. Someone who remembers your name.\n\nAt Aureline, we make room for those little moments. A considered collection of rooms, spaces to unwind, and hospitality shaped by Sorsogon’s easy coastal warmth.',
            style: bodyStyle)
      ]));
  Widget _amenities() => Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      color: paleGreen,
      child: const Column(children: [
        Amenity(
            icon: Icons.wifi,
            title: 'Stay connected',
            detail: 'Complimentary Wi-Fi'),
        Amenity(
            icon: Icons.coffee_outlined,
            title: 'Mornings, made better',
            detail: 'Breakfast offers'),
        Amenity(
            icon: Icons.waves,
            title: 'Sorsogon escapes',
            detail: 'City and coastal access'),
        Amenity(
            icon: Icons.eco_outlined,
            title: 'Save on stays',
            detail: 'Up to 15% off')
      ]));
  Widget _offers() => Container(
      padding: const EdgeInsets.fromLTRB(25, 38, 25, 38),
      color: const Color(0xFFFFFEF9),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('LIMITED OFFERS', style: eyebrowStyle),
        const SizedBox(height: 13),
        const Text('Stay a little longer in Sorsogon.', style: sectionStyle),
        const SizedBox(height: 20),
        const OfferTile(
            title: '15% off suites',
            detail: 'Book two nights or more in Deluxe or Suite rooms.'),
        const OfferTile(
            title: '10% weekday escape',
            detail: 'Save on Sunday to Thursday stays.'),
        const OfferTile(
            title: 'Breakfast bundle',
            detail: 'Add breakfast for two at a special rate.')
      ]));
  Widget _collection(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('THE AURELINE COLLECTION', style: eyebrowStyle),
        const SizedBox(height: 18),
        const Text('Your own little retreat.', style: sectionStyle),
        const SizedBox(height: 8),
        const Text(
            'Four ways to settle in. One feeling of being right where you belong.',
            style: bodyStyle),
        const SizedBox(height: 22),
        ...List.generate(
            3,
            (index) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: PublicRoomCard(index: index + 1)))
      ]));
  Widget _experienceFeature() => Container(
      color: const Color(0xFFEDF1E5),
      child: Column(children: [
        Image.network(
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=85',
            height: 245,
            width: double.infinity,
            fit: BoxFit.cover),
        const Padding(
            padding: EdgeInsets.all(28),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SAVOR THE SLOW MOMENTS', style: eyebrowStyle),
              SizedBox(height: 18),
              Text('A little less rushing.\nA little more living.',
                  style: sectionStyle),
              SizedBox(height: 18),
              Text(
                  'A leisurely breakfast. An afternoon by the water. Conversations that last a little longer.',
                  style: bodyStyle)
            ]))
      ]));
  Widget _experiences() => Padding(
      padding: const EdgeInsets.fromLTRB(25, 58, 25, 55),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MAKE YOUR STAY YOUR OWN', style: eyebrowStyle),
        const SizedBox(height: 18),
        const Text('More than a room key.', style: sectionStyle),
        const SizedBox(height: 22),
        const ExperienceTile(
            label: 'AT THE TABLE',
            title: 'Good food. Better company.',
            image:
                'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=85'),
        const ExperienceTile(
            label: 'ROOM TO BREATHE',
            title: 'Do a little less.',
            image:
                'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=85'),
        const ExperienceTile(
            label: 'MOMENTS THAT MATTER',
            title: 'Bring your people together.',
            image:
                'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=85')
      ]));
  Widget _invitation(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 58, horizontal: 25),
      color: const Color(0xFFF1F3E9),
      child: Column(children: [
        const Icon(Icons.eco_outlined, color: sage, size: 28),
        const SizedBox(height: 20),
        const Text('YOUR ROOM IS WAITING', style: eyebrowStyle),
        const SizedBox(height: 18),
        const Text('Come for a stay.\nLeave with a story.',
            textAlign: TextAlign.center, style: sectionStyle),
        const SizedBox(height: 24),
        FilledButton(
            onPressed: () => Navigator.pushNamed(context, '/sign-in'),
            style: FilledButton.styleFrom(
                backgroundColor: forest, foregroundColor: Colors.white),
            child: const Text('Plan your stay'))
      ]));
}

class Amenity extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  const Amenity(
      {super.key,
      required this.icon,
      required this.title,
      required this.detail});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Icon(icon, color: sage, size: 22),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: sage, fontSize: 11)),
          const SizedBox(height: 4),
          Text(detail, style: const TextStyle(color: muted, fontSize: 9))
        ])
      ]));
}

class OfferTile extends StatelessWidget {
  final String title;
  final String detail;
  const OfferTile({super.key, required this.title, required this.detail});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF7F8F0),
          border: Border.all(color: const Color(0xFFE2E8D7)),
          borderRadius: BorderRadius.circular(6)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(color: Color(0xFF60794F), fontSize: 13)),
        const SizedBox(height: 8),
        Text(detail, style: bodyStyle)
      ]));
}

class PublicRoomCard extends StatelessWidget {
  final int index;
  const PublicRoomCard({super.key, required this.index});
  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(6)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            height: 220,
            width: double.infinity,
            child: Image.network(roomImages[index], fit: BoxFit.cover)),
        Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rooms[index][0],
                  style: const TextStyle(
                      color: ink, fontFamily: 'Georgia', fontSize: 22)),
              const SizedBox(height: 8),
              Text(rooms[index][1], style: bodyStyle),
              const SizedBox(height: 14),
              Text(rooms[index][2],
                  style: const TextStyle(color: muted, fontSize: 10))
            ]))
      ]));
}

class _AvailableRoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final VoidCallback onTap;
  const _AvailableRoomCard({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final roomType = room['type'] as String? ?? 'Double';
    final inclusions = roomInclusions[roomType] ?? [];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(7),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.network(
              room['image'] as String? ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: paleGreen,
                  child: const Icon(Icons.bed, size: 48, color: muted),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                roomType,
                style: const TextStyle(
                  color: ink,
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.people, size: 14, color: sage),
                  const SizedBox(width: 4),
                  Text(
                    '${room['capacity'] as int? ?? 1} guest${(room['capacity'] as int? ?? 1) > 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.bed, size: 14, color: sage),
                  const SizedBox(width: 4),
                  const Text(
                    'King bed',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₱${(room['price'] as num?)?.toStringAsFixed(2) ?? '0.00'} / night',
                    style: const TextStyle(
                      color: forest,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 16, color: forest),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Room amenities', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ink)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: inclusions.take(3).map((inclusion) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 12, color: forest),
                    const SizedBox(width: 4),
                    Text(
                      inclusion,
                      style: const TextStyle(fontSize: 10, color: muted),
                    ),
                  ],
                )).toList(),
              ),
              if (inclusions.length > 3)
                Text(
                  '+${inclusions.length - 3} more',
                  style: const TextStyle(fontSize: 10, color: forest),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class ExperienceTile extends StatelessWidget {
  final String label;
  final String title;
  final String image;
  const ExperienceTile(
      {super.key,
      required this.label,
      required this.title,
      required this.image});
  @override
  Widget build(BuildContext context) => Container(
      height: 260,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.cover,
              colorFilter:
                  const ColorFilter.mode(Color(0x770F221A), BlendMode.darken))),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFFD0D8C6), letterSpacing: 1.8, fontSize: 8)),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'Georgia', fontSize: 25))
          ]));
}
