import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../data/room_inclusions.dart';
import '../../services/auth_service.dart';
import '../../services/account_store.dart';
import '../common/widgets.dart';

class GuestRoomDetailsScreen extends StatefulWidget {
  const GuestRoomDetailsScreen({super.key});
  @override
  State<GuestRoomDetailsScreen> createState() => _GuestRoomDetailsScreenState();
}

class _GuestRoomDetailsScreenState extends State<GuestRoomDetailsScreen> {
  Map<String, dynamic>? room;
  String? checkIn;
  String? checkOut;
  int? guests;
  bool booking = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        room = args['room'] as Map<String, dynamic>;
        checkIn = args['checkIn'] as String;
        checkOut = args['checkOut'] as String;
        guests = args['guests'] as int;
      });
    }
  }

  int _calculateNights() {
    if (checkIn == null || checkOut == null) return 0;
    final start = DateTime.parse(checkIn!);
    final end = DateTime.parse(checkOut!);
    return end.difference(start).inDays;
  }

  double _calculateTotal() {
    if (room == null) return 0;
    final price = (room!['price'] as num).toDouble();
    return price * _calculateNights();
  }

  Future<void> _bookRoom() async {
    if (room == null || checkIn == null || checkOut == null || guests == null) {
      showAppMessage(context, 'Missing booking information');
      return;
    }

    setState(() => booking = true);

    try {
      final token = AccountStore.instance.token;
      if (token == null) {
        throw Exception('You must be logged in to book a room');
      }

      final result = await AuthService.createReservation(
        roomId: room!['id'] as String,
        checkIn: checkIn!,
        checkOut: checkOut!,
        guests: guests!,
        token: token,
      );

      if (mounted) {
        showAppMessage(context, 'Reservation created successfully!');
        Navigator.of(context).popUntil((route) => route.isFirst);
        // Navigate to guest stays tab
        Navigator.pushReplacementNamed(context, '/hotel');
      }
    } catch (e) {
      if (mounted) {
        showAppMessage(context, 'Failed to create reservation: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      if (mounted) {
        setState(() => booking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (room == null) {
      return Scaffold(
        backgroundColor: cream,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final nights = _calculateNights();
    final total = _calculateTotal();

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RoomImage(),
              _RoomDetails(),
              _BookingSummary(nights: nights, total: total),
              _BookButton(booking: booking),
            ],
          ),
        ),
      ),
    );
  }

  Widget _RoomImage() {
    return Stack(
      children: [
        if (room!['image'] != null)
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Image.network(
              room!['image'] as String,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: paleGreen,
                  child: const Icon(Icons.bed, size: 64, color: muted),
                );
              },
            ),
          ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.5)),
          ),
        ),
      ],
    );
  }

  Widget _RoomDetails() {
    final roomType = room!['type'] as String? ?? 'Double';
    final inclusions = roomInclusions[roomType] ?? [];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room!['type'] as String? ?? 'Room',
            style: GoogleFonts.playfairDisplay(fontSize: 32, color: ink, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '₱${room!['price']}/night',
            style: const TextStyle(fontSize: 18, color: forest, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (room!['description'] != null)
            Text(
              room!['description'] as String,
              style: const TextStyle(fontSize: 14, color: muted, height: 1.5),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.people, size: 16, color: muted),
              const SizedBox(width: 8),
              Text(
                'Capacity: ${room!['capacity']} guest${room!['capacity'] == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 14, color: muted),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Room amenities', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ink)),
          const SizedBox(height: 12),
          ...inclusions.map((inclusion) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: forest),
                const SizedBox(width: 8),
                Text(
                  inclusion,
                  style: const TextStyle(fontSize: 14, color: muted),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _BookingSummary({required int nights, required double total}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ink)),
          const SizedBox(height: 16),
          _SummaryRow('Check-in', checkIn ?? ''),
          const SizedBox(height: 8),
          _SummaryRow('Check-out', checkOut ?? ''),
          const SizedBox(height: 8),
          _SummaryRow('Guests', '$guests'),
          const SizedBox(height: 8),
          _SummaryRow('Nights', '$nights'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ink)),
              Text(
                '₱${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: forest),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _SummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: muted)),
        Text(value, style: const TextStyle(fontSize: 14, color: ink)),
      ],
    );
  }

  Widget _BookButton({required bool booking}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: booking ? null : _bookRoom,
          style: FilledButton.styleFrom(
            backgroundColor: forest,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: booking
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Confirm Booking'),
        ),
      ),
    );
  }
}
