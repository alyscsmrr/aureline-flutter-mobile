import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../data/hotel_data.dart';
import '../../theme/app_theme.dart';

void showAppMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));

class Brand extends StatelessWidget {
  final bool light;
  const Brand({super.key, this.light = false});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 34,
          height: 46,
          alignment: Alignment.center,
          decoration: const ShapeDecoration(shape: _ArchShapeBorder()),
          child: Stack(alignment: Alignment.center, children: [
            Text('A', style: GoogleFonts.playfairDisplay(color: gold, fontSize: 27)),
            const Positioned(top: 1, child: Text('✦', style: TextStyle(color: gold, fontSize: 8))),
          ]),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AURELINE', style: GoogleFonts.dmSans(color: light ? Colors.white : ink, fontSize: 15, letterSpacing: 2.2, fontWeight: FontWeight.w600)),
          Text('H O T E L', style: GoogleFonts.dmSans(color: light ? const Color(0xFFD4DCC8) : sage, fontSize: 7, letterSpacing: 3.2, fontWeight: FontWeight.w600)),
        ])
      ]);
}

class _ArchShapeBorder extends ShapeBorder {
  const _ArchShapeBorder();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  Path _path(Rect rect) {
    final inset = 1.0;
    final r = rect.deflate(inset);
    return Path()
      ..moveTo(r.left, r.bottom)
      ..lineTo(r.left, r.top + 14)
      ..quadraticBezierTo(r.center.dx, r.top - 1, r.right, r.top + 14)
      ..lineTo(r.right, r.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(_path(rect), paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}

class HotelTopBar extends StatelessWidget {
  const HotelTopBar({super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 4),
      child: Row(children: [
        const Brand(),
        const Spacer(),
        IconButton(
            onPressed: () => showAppMessage(context, 'No new notifications.'),
            icon: const Icon(Icons.notifications_none, color: forest)),
        const CircleAvatar(
            radius: 17,
            backgroundColor: paleGreen,
            child: Text('D',
                style: TextStyle(color: forest, fontWeight: FontWeight.w600)))
      ]));
}

class PublicHeader extends StatelessWidget {
  const PublicHeader({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
          color: forest,
          child: const Center(
              child: Text(
                  'Sorsogon City, Philippines.   Enjoy up to 15% off selected stays.',
                  style: TextStyle(
                      color: Color(0xFFE2E6D9),
                      fontSize: 8,
                      letterSpacing: .4))),
        ),
        LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth <= 600;
          return Container(
              decoration: const BoxDecoration(
                  color: Color(0xFFFFFEFB),
                  border: Border(bottom: BorderSide(color: border))),
              padding: EdgeInsets.fromLTRB(compact ? 18 : 22, 16, compact ? 14 : 18, 16),
              child: Row(children: [
                const Brand(),
                const Spacer(),
                IconButton(
                    tooltip: 'Sign in',
                    onPressed: () => Navigator.pushNamed(context, '/sign-in'),
                    icon: const Icon(Icons.person_outline, color: forest)),
                if (!compact)
                  FilledButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/hotel', (route) => false),
                      style: FilledButton.styleFrom(
                          backgroundColor: forest,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10)),
                      child: const Text('Book your stay', style: TextStyle(fontSize: 10))),
                if (compact)
                  IconButton(
                      tooltip: 'Menu',
                      onPressed: () => showAppMessage(context, 'Use the sections below to explore Aureline.'),
                      icon: const Icon(Icons.menu, color: forest))
              ]));
        }),
      ]);
}

class PageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final Widget? action;
  const PageHeader(
      {super.key,
      required this.eyebrow,
      required this.title,
      required this.description,
      this.action});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(eyebrow, style: eyebrowStyle),
          const SizedBox(height: 8),
          Text(title, style: displayStyle),
          const SizedBox(height: 8),
          Text(description, style: bodyStyle)
        ])),
        if (action != null) action!
      ]));
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: status == 'Pending'
              ? const Color(0xFFF5EFE1)
              : const Color(0xFFE8F0E5),
          borderRadius: BorderRadius.circular(3)),
      child: Text(status,
          style: TextStyle(
              color: status == 'Pending'
                  ? const Color(0xFF9A7B45)
                  : const Color(0xFF66805D),
              fontSize: 9)));
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String detail;
  const StatCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      required this.detail});
  @override
  Widget build(BuildContext context) => Container(
      width: 184,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(7)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: muted, fontSize: 10))),
          Icon(icon, size: 19, color: sage)
        ]),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(
                color: ink, fontFamily: 'Georgia', fontSize: 29)),
        const Spacer(),
        Row(children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  const BoxDecoration(color: gold, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Expanded(
              child: Text(detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: muted, fontSize: 9)))
        ])
      ]));
}

class ReservationPanel extends StatelessWidget {
  const ReservationPanel({super.key});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 8),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
          children: reservations
              .map((stay) => ReservationRow(
                  name: stay[0], room: stay[1], time: stay[2], status: stay[3]))
              .toList()));
}

class ReservationRow extends StatelessWidget {
  final String name;
  final String room;
  final String time;
  final String status;
  const ReservationRow(
      {super.key,
      required this.name,
      required this.room,
      required this.time,
      required this.status});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF0F1E9)))),
      child: Row(children: [
        CircleAvatar(
            radius: 19,
            backgroundColor: paleGreen,
            child: Text(name.substring(0, 1),
                style: const TextStyle(color: forest, fontSize: 13))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: const TextStyle(
                  color: ink, fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 4),
          Text('$room · $time',
              style: const TextStyle(color: muted, fontSize: 10))
        ])),
        StatusBadge(status)
      ]));
}

class RoomCard extends StatelessWidget {
  final int index;
  const RoomCard({super.key, required this.index});
  @override
  Widget build(BuildContext context) {
    final room = rooms[index];
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(7)),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              height: 170,
              width: double.infinity,
              child: Image.network(roomImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: paleGreen))),
          Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room[0],
                        style: const TextStyle(
                            color: ink, fontFamily: 'Georgia', fontSize: 21)),
                    const SizedBox(height: 6),
                    Text(room[1],
                        style: const TextStyle(color: muted, fontSize: 11)),
                    const SizedBox(height: 14),
                    Row(children: [
                      const Icon(Icons.square_foot, size: 15, color: sage),
                      const SizedBox(width: 5),
                      Text(room[2],
                          style: const TextStyle(color: muted, fontSize: 10)),
                      const Spacer(),
                      TextButton(
                          onPressed: () =>
                              showAppMessage(context, '${room[0]} selected.'),
                          child: const Text('Manage →',
                              style: TextStyle(color: forest, fontSize: 11)))
                    ])
                  ]))
        ]));
  }
}
