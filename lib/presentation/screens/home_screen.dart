import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/hotel_data.dart';
import '../../theme/app_theme.dart';
import '../common/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: PublicHeader()),
        SliverToBoxAdapter(child: _hero(context)),
        SliverToBoxAdapter(child: _bookingBar(context)),
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
                Expanded(child: _dateField('Check-in', '10/11/2026')),
                const SizedBox(width: 10),
                Expanded(child: _dateField('Check-out', '10/13/2026'))
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _dateField('Guests', '2 guests')),
                const SizedBox(width: 10),
                FilledButton(
                    onPressed: () =>
                        showAppMessage(context, 'Finding your room...'),
                    style: FilledButton.styleFrom(
                        backgroundColor: forest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15)),
                    child: const Text('Find your room',
                        style: TextStyle(fontSize: 10)))
              ])
            ])),
      );
  Widget _dateField(String label, String value) => Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(3)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: sage, fontSize: 8)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: ink, fontSize: 11))
      ]));
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
            onPressed: () => showAppMessage(context, 'Plan your stay.'),
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
