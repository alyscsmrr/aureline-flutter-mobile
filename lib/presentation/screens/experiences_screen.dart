import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../common/widgets.dart';

class ExperiencesScreen extends StatelessWidget {
  const ExperiencesScreen({super.key});

  static const items = [
    _ExperienceData('AT THE TABLE', 'Good food. Better company.', 'Gather around a beautifully laid table, seasonal produce, and easy conversation. Our dining spaces make slowing down feel natural.', 'The Veranda · Breakfast, lunch & dinner', 'Open daily · 7:00 AM – 10:00 PM', 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=85'),
    _ExperienceData('ROOM TO BREATHE', 'Do a little less.', 'A quiet day by the water is sometimes exactly what you need. Find your pace beside the pool or let the afternoon take its time.', 'Poolside · Day beds & refreshments', 'Open daily · 8:00 AM – 8:00 PM', 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=1200&q=85'),
    _ExperienceData('MOMENTS THAT MATTER', 'Bring your people together.', 'From intimate dinners to a weekend worth remembering, our spaces are made for the people and moments you want to keep close.', 'The Gathering · Small celebrations', 'Plan something lovely · By arrangement', 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=85'),
  ];

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: PublicHeader()),
        const SliverToBoxAdapter(child: Padding(
          padding: EdgeInsets.fromLTRB(25, 52, 25, 38),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text('THE AURELINE EXPERIENCE', style: eyebrowStyle),
            SizedBox(height: 16),
            Text('Make room for the good things.', textAlign: TextAlign.center, style: displayStyle),
            SizedBox(height: 12),
            Text('A meal to remember. A moment of calm.\nA little more of what makes you feel like you.', textAlign: TextAlign.center, style: bodyStyle),
          ]),
        )),
        SliverToBoxAdapter(child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 680;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 42 : 20),
            child: Column(children: [
              for (var i = 0; i < items.length; i++)
                _ExperienceRow(data: items[i], reverse: i.isOdd, wide: wide),
            ]),
          );
        })),
        const SliverToBoxAdapter(child: _AurelineFooter()),
      ]);
}

class _ExperienceData {
  final String label, title, description, detail, hours, image;
  const _ExperienceData(this.label, this.title, this.description, this.detail, this.hours, this.image);
}

class _ExperienceRow extends StatelessWidget {
  final _ExperienceData data;
  final bool reverse, wide;
  const _ExperienceRow({required this.data, required this.reverse, required this.wide});

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.network(data.image, height: wide ? 190 : 230, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: paleGreen)));
    final copy = Padding(padding: EdgeInsets.fromLTRB(wide ? 22 : 4, wide ? 4 : 22, wide ? 8 : 4, wide ? 4 : 34), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(data.label, style: eyebrowStyle),
      const SizedBox(height: 12),
      Text(data.title, style: sectionStyle),
      const SizedBox(height: 12),
      Text(data.description, style: bodyStyle),
      const SizedBox(height: 12),
      Text(data.detail, style: const TextStyle(color: muted, fontSize: 10)),
      const SizedBox(height: 6),
      Row(children: [const Icon(Icons.schedule, color: sage, size: 13), const SizedBox(width: 6), Text(data.hours, style: const TextStyle(color: muted, fontSize: 10))]),
      const SizedBox(height: 13),
      TextButton.icon(onPressed: () => Navigator.pushNamed(context, '/contact'), icon: const Icon(Icons.arrow_upward, size: 14), label: const Text('Plan something lovely'), style: TextButton.styleFrom(foregroundColor: forest, padding: EdgeInsets.zero)),
    ]));

    return Padding(
      padding: EdgeInsets.only(bottom: wide ? 28 : 10),
      child: wide ? Row(children: [Expanded(child: reverse ? copy : image), Expanded(child: reverse ? image : copy)]) : Column(children: [image, copy]),
    );
  }
}

class _AurelineFooter extends StatelessWidget {
  const _AurelineFooter();
  @override
  Widget build(BuildContext context) => Container(
        color: deepForest,
        padding: const EdgeInsets.fromLTRB(25, 38, 25, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Brand(light: true),
          const SizedBox(height: 18),
          const Text('Some places are visited.\nOthers stay with you.', style: TextStyle(color: Color(0xFFD3DCC8), fontSize: 10, height: 1.7)),
          const SizedBox(height: 30),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _FooterColumn(title: 'MAKE YOURSELF AT HOME', links: const ['Rooms & suites', 'The Aureline experience', 'Plan your visit'])),
            Expanded(child: _FooterColumn(title: 'YOUR STAY', links: const ['Find a room', 'Sign in', 'Create an account'])),
          ]),
          const SizedBox(height: 30),
          const Divider(color: Color(0x557A9A83)),
          const SizedBox(height: 12),
          const Text('Copyright 2026 Aureline Hotel', style: TextStyle(color: Color(0xFFB5C6B2), fontSize: 8)),
        ]),
      );
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  const _FooterColumn({required this.title, required this.links});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Color(0xFFB5C6B2), fontSize: 7, letterSpacing: 1.4)),
        const SizedBox(height: 10),
        ...links.map((link) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text(link, style: const TextStyle(color: Color(0xFFD3DCC8), fontSize: 9)))),
      ]);
}
