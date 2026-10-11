import 'package:flutter/material.dart';
import '../common/widgets.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: HotelTopBar()),
        const SliverToBoxAdapter(
            child: PageHeader(
                eyebrow: 'AURELINE HOTEL',
                title: 'Reservations',
                description:
                    'Keep every arrival, stay, and goodbye beautifully organized.')),
        const SliverToBoxAdapter(child: ReservationPanel())
      ]);
}
