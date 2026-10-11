import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../common/widgets.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: HotelTopBar()),
        SliverToBoxAdapter(
            child: PageHeader(
                eyebrow: 'TODAY AT AURELINE',
                title: 'A lovely day to host.',
                description:
                    'Here is what is happening at Aureline Hotel today.',
                action: Icon(Icons.notifications_none, color: forest))),
        SliverToBoxAdapter(child: _hero(context)),
        SliverToBoxAdapter(child: _stats()),
        const SliverToBoxAdapter(
            child: Padding(
                padding: EdgeInsets.fromLTRB(22, 28, 22, 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reservation activity', style: sectionStyle),
                      SizedBox(height: 5),
                      Text('Every arrival is the beginning of something good.',
                          style: bodyStyle)
                    ]))),
        const SliverToBoxAdapter(child: ReservationPanel()),
        SliverToBoxAdapter(child: _note()),
        const SliverToBoxAdapter(child: SizedBox(height: 18))
      ]);

  Widget _hero(BuildContext context) => Container(
      height: 230,
      margin: const EdgeInsets.fromLTRB(18, 4, 18, 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(
              image: NetworkImage(heroImage),
              fit: BoxFit.cover,
              colorFilter:
                  ColorFilter.mode(Color(0xAA14251F), BlendMode.darken))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('THE ART OF A WELCOMING STAY',
                style: TextStyle(
                    color: Color(0xFFE0E3CF), fontSize: 9, letterSpacing: 1.8)),
            const SizedBox(height: 10),
            const Text('Every stay, a story.',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Georgia', fontSize: 28)),
            const Text('Make this one exceptional.',
                style: TextStyle(
                    color: Color(0xFFDCE5D5),
                    fontFamily: 'Georgia',
                    fontSize: 18)),
            const SizedBox(height: 14),
            TextButton.icon(
                onPressed: () =>
                    showAppMessage(context, 'Room management is ready.'),
                icon: const Icon(Icons.arrow_upward, size: 15),
                label: const Text('Explore our rooms'),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white, padding: EdgeInsets.zero))
          ]));
  Widget _stats() {
    const data = [
      [
        'Available rooms',
        '08',
        Icons.check_circle_outline,
        'Ready for a warm welcome'
      ],
      ['Occupied rooms', '14', Icons.bed_outlined, 'Guests currently in house'],
      ["Today's check-ins", '06', Icons.login, '2 checked in so far'],
      ["Today's check-outs", '04', Icons.logout, 'Make the goodbye lovely']
    ];
    return SizedBox(
        height: 144,
        child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) => StatCard(
                label: data[index][0] as String,
                value: data[index][1] as String,
                icon: data[index][2] as IconData,
                detail: data[index][3] as String)));
  }

  Widget _note() => Container(
      margin: const EdgeInsets.fromLTRB(18, 24, 18, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: paleGreen,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8)),
      child: const Row(children: [
        Icon(Icons.eco_outlined, color: sage, size: 24),
        SizedBox(width: 15),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Good hospitality is in the details.',
              style: TextStyle(
                  color: forest, fontFamily: 'Georgia', fontSize: 16)),
          SizedBox(height: 6),
          Text(
              'A smooth check-in. A remembered name. A room that feels just right.',
              style: bodyStyle)
        ]))
      ]));
}
