import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/hotel_data.dart';
import '../common/widgets.dart';

class GuestsScreen extends StatelessWidget {
  const GuestsScreen({super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        const SliverToBoxAdapter(child: HotelTopBar()),
        const SliverToBoxAdapter(
            child: PageHeader(
                eyebrow: 'YOUR GUESTS',
                title: 'Guest records',
                description:
                    'A thoughtful stay starts with remembering the details.')),
        SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                        children: guests
                            .map((guest) => ListTile(
                                leading: CircleAvatar(
                                    backgroundColor: paleGreen,
                                    child: Text(guest[0],
                                        style: const TextStyle(color: forest))),
                                title: Text(guest,
                                    style: const TextStyle(
                                        color: ink,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                subtitle: const Text(
                                    'Guest profile · Recent stay',
                                    style:
                                        TextStyle(color: muted, fontSize: 10)),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 13, color: sage)))
                            .toList()))))
      ]);
}
