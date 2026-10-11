import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../common/widgets.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: cream,
        body: SafeArea(
          child: CustomScrollView(slivers: [
            const SliverToBoxAdapter(child: PublicHeader()),
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.fromLTRB(25, 50, 25, 35),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text('PLAN YOUR AURELINE STAY', style: eyebrowStyle),
                SizedBox(height: 16),
                Text('Plan your Aureline stay.', textAlign: TextAlign.center, style: displayStyle),
                SizedBox(height: 12),
                Text('Questions, requests, or simply want to say hello?\nWe would love to hear from you.', textAlign: TextAlign.center, style: bodyStyle),
              ]),
            )),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(builder: (context, constraints) {
                final wide = constraints.maxWidth >= 680;
                final image = ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.network('https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=1200&q=85', height: wide ? 270 : 230, width: double.infinity, fit: BoxFit.cover));
                final info = Padding(padding: EdgeInsets.fromLTRB(wide ? 25 : 4, wide ? 8 : 22, 4, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('GET IN TOUCH', style: eyebrowStyle),
                  const SizedBox(height: 14),
                  const Text('Contact information.', style: sectionStyle),
                  const SizedBox(height: 20),
                  const _ContactLine(icon: Icons.location_on_outlined, label: 'Address', value: 'Aureline Hotel, Sorsogon City, Philippines'),
                  const _ContactLine(icon: Icons.phone_outlined, label: 'Reservations', value: '+63 917 234 5678'),
                  const _ContactLine(icon: Icons.mail_outline, label: 'Email', value: 'hello@aureline.hotel'),
                  const _ContactLine(icon: Icons.schedule, label: 'Arrival & departure', value: 'Check-in from 2:00 PM\nCheckout by 12:00 PM'),
                  const SizedBox(height: 10),
                  TextButton.icon(onPressed: () => showAppMessage(context, 'We would love to help plan your stay.'), icon: const Icon(Icons.arrow_upward, size: 14), label: const Text('Send us a note'), style: TextButton.styleFrom(foregroundColor: forest, padding: EdgeInsets.zero)),
                ]));
                return wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: image), Expanded(child: info)]) : Column(children: [image, info]);
              }),
            )),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 35, 20, 45), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('GETTING TO AURELINE HOTEL', style: eyebrowStyle),
              const SizedBox(height: 14),
              const Text('A little easier to find.', style: sectionStyle),
              const SizedBox(height: 16),
              Row(children: const [Expanded(child: _InfoCard(icon: Icons.flight_outlined, title: 'By air', text: 'Fly to Bicol International Airport, then continue by private transfer or taxi.')), SizedBox(width: 10), Expanded(child: _InfoCard(icon: Icons.directions_car_outlined, title: 'By car', text: 'A scenic drive through Sorsogon brings you to the hotel.'))]),
            ]))),
            const SliverToBoxAdapter(child: _AttractionsSection()),
            const SliverToBoxAdapter(child: _ReviewsSection()),
            const SliverToBoxAdapter(child: _FaqSection()),
            const SliverToBoxAdapter(child: _ContactFooter()),
          ]),
        ),
      );
}

class _ContactLine extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ContactLine({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: sage, size: 16), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: sage, fontSize: 9)), const SizedBox(height: 3), Text(value, style: const TextStyle(color: muted, fontSize: 10, height: 1.45))]))]));
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, text;
  const _InfoCard({required this.icon, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFFFFEF9), border: Border.all(color: border), borderRadius: BorderRadius.circular(3)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: sage, size: 16), const SizedBox(height: 10), Text(title, style: const TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w600)), const SizedBox(height: 7), Text(text, style: const TextStyle(color: muted, fontSize: 9, height: 1.5))]));
}

class _AttractionsSection extends StatelessWidget {
  const _AttractionsSection();
  static const places = [
    ['Culture', 'Museo Sorsogon', 'A heritage stop with galleries on Sorsogon history, communities, and local identity.'],
    ['City walk', 'Rompeolas Baywalk', 'A relaxed waterfront area for sunset strolls, photos, and easy evenings near the city.'],
    ['Beach', 'Paguriran Island', 'A scenic island and beach escape known for clear water and a natural lagoon setting.'],
    ['Nature', 'Bulusan Lake', 'A peaceful lake in Bulusan Volcano Natural Park, ideal for nature trips and quiet views.'],
    ['Adventure', 'Donsol Whale Shark Interaction', 'A famous Sorsogon experience for seasonal whale shark watching and marine encounters.'],
    ['Heritage', 'Barcelona Ruins', 'A historic stone church ruin and coastal heritage stop in the town of Barcelona.'],
  ];
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 45), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('NEARBY ATTRACTIONS', style: eyebrowStyle),
    const SizedBox(height: 12),
    const Text('Places to see in Sorsogon.', style: sectionStyle),
    const SizedBox(height: 16),
    LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 680 ? 3 : 1;
      return Wrap(spacing: 10, runSpacing: 10, children: places.map((place) => SizedBox(width: columns == 3 ? (constraints.maxWidth - 20) / 3 : constraints.maxWidth, child: _PlaceCard(category: place[0], title: place[1], text: place[2]))).toList());
    }),
  ]));
}

class _PlaceCard extends StatelessWidget {
  final String category, title, text;
  const _PlaceCard({required this.category, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFFFFEF9), border: Border.all(color: border), borderRadius: BorderRadius.circular(4)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(category, style: const TextStyle(color: sage, fontSize: 8, letterSpacing: 1.2)), const SizedBox(height: 12), Text(title, style: const TextStyle(color: forest, fontSize: 11, fontWeight: FontWeight.w500)), const SizedBox(height: 8), Text(text, style: const TextStyle(color: muted, fontSize: 9, height: 1.55))]));
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 48), child: LayoutBuilder(builder: (context, constraints) {
    final reviews = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('GUEST REVIEWS', style: eyebrowStyle),
      const SizedBox(height: 12),
      const Text('Kind words from recent stays.', style: sectionStyle),
      const SizedBox(height: 16),
      Wrap(spacing: 10, runSpacing: 10, children: const [
        _ReviewCard(text: 'The rooms feel calm and elegant. Staff made check-in easy and helped us plan a Sorsogon day trip.', name: 'Isabella R.'),
        _ReviewCard(text: 'Great location for a city stay. The breakfast bundle and weekday offer made the reservation worth it.', name: 'Miguel A.'),
        _ReviewCard(text: 'Loved the quiet design and the guest account page. Everything about our stay was easy to follow.', name: 'Sofia C.'),
      ]),
    ]);
    final reward = Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: paleGreen, border: Border.all(color: border), borderRadius: BorderRadius.circular(4)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.card_giftcard_outlined, color: sage, size: 18), const SizedBox(height: 10), const Text('AURELINE REWARDS', style: TextStyle(color: sage, fontSize: 8, letterSpacing: 1.2)), const SizedBox(height: 13), const Text('More reasons to return.', style: sectionStyle), const SizedBox(height: 12), const Text('•  Earn stay credits for every confirmed reservation.\n\n•  Get priority access to selected weekday and suite discounts.\n\n•  Receive birthday treats, breakfast offers, and late checkout when available.', style: TextStyle(color: muted, fontSize: 9, height: 1.6)), const SizedBox(height: 16), FilledButton(onPressed: () => Navigator.pushNamed(context, '/sign-up'), child: const Text('Join as a guest'))]));
    return constraints.maxWidth >= 680 ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: reviews), const SizedBox(width: 16), Expanded(flex: 2, child: reward)]) : Column(children: [reviews, const SizedBox(height: 18), reward]);
  }));
}

/* class _ReviewCard extends StatelessWidget {
  final String text, name;
  const _ReviewCard({required this.text, required this.name});
  @override
  Widget build(BuildContext context) => SizedBox(width: 160, child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFFFFEF9), border: Border.all(color: border), borderRadius: BorderRadius.circular(4)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('★★★★★', style: TextStyle(color: gold, fontSize: 11)), const SizedBox(height: 10), Text(text, style: const TextStyle(color: muted, fontSize: 9, height: 1.55)), const SizedBox(height: 10), Text(name, style: const TextStyle(color: forest, fontSize: 9, fontWeight: FontWeight.w600))]));
}

*/

class _ReviewCard extends StatelessWidget {
  final String text, name;
  const _ReviewCard({required this.text, required this.name});
  @override
  Widget build(BuildContext context) => Container(
        width: 160,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: const Color(0xFFFFFEF9), border: Border.all(color: border), borderRadius: BorderRadius.circular(4)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('★★★★★', style: TextStyle(color: gold, fontSize: 11)),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: muted, fontSize: 9, height: 1.55)),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(color: forest, fontSize: 9, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();
  static const questions = ['Where is Aureline Hotel located?', 'What time are check-in and checkout?', 'How do I make a reservation?', 'Are there discounts or offers?', 'Can I change or cancel my stay?', 'Is payment taken when I book?'];
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 55), child: LayoutBuilder(builder: (context, constraints) => constraints.maxWidth >= 680 ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('A LITTLE CLARITY', style: eyebrowStyle), SizedBox(height: 14), Text('Happy to help.', style: displayStyle)])), Expanded(child: Column(children: questions.map((q) => _FaqRow(question: q)).toList()))]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('A LITTLE CLARITY', style: eyebrowStyle), const SizedBox(height: 14), const Text('Happy to help.', style: displayStyle), const SizedBox(height: 20), ...questions.map((q) => _FaqRow(question: q))])));
}

class _FaqRow extends StatelessWidget {
  final String question;
  const _FaqRow({required this.question});
  @override
  Widget build(BuildContext context) => ExpansionTile(title: Text(question, style: const TextStyle(color: muted, fontSize: 10)), children: const [Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 12), child: Align(alignment: Alignment.centerLeft, child: Text('Our team would be happy to help with this when you plan your stay.', style: TextStyle(color: muted, fontSize: 9))))]);
}

class _ContactFooter extends StatelessWidget {
  const _ContactFooter();
  @override
  Widget build(BuildContext context) => Container(color: deepForest, padding: const EdgeInsets.fromLTRB(25, 38, 25, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Brand(light: true), const SizedBox(height: 16), const Text('Some places are visited.\nOthers stay with you.', style: TextStyle(color: Color(0xFFD3DCC8), fontSize: 10, height: 1.7)), const SizedBox(height: 26), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _FooterLinks(title: 'MAKE YOURSELF AT HOME', links: const ['Rooms & suites', 'The Aureline experience', 'Plan your visit'])), Expanded(child: _FooterLinks(title: 'YOUR STAY', links: const ['Find a room', 'Sign in', 'Create an account']))]), const SizedBox(height: 26), const Divider(color: Color(0x557A9A83)), const SizedBox(height: 10), const Text('Copyright 2026 Aureline Hotel', style: TextStyle(color: Color(0xFFB5C6B2), fontSize: 8))]));
}

class _FooterLinks extends StatelessWidget {
  final String title;
  final List<String> links;
  const _FooterLinks({required this.title, required this.links});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Color(0xFFB5C6B2), fontSize: 7, letterSpacing: 1.2)), const SizedBox(height: 10), ...links.map((link) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text(link, style: const TextStyle(color: Color(0xFFD3DCC8), fontSize: 9))))]);
}
