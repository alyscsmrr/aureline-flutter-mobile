import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../services/account_store.dart';
import '../../services/auth_service.dart';
import '../common/widgets.dart';

class GuestStaysScreen extends StatefulWidget {
  const GuestStaysScreen({super.key});
  @override
  State<GuestStaysScreen> createState() => _GuestStaysScreenState();
}

class _GuestStaysScreenState extends State<GuestStaysScreen> {
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> rooms = [];
  bool loading = true;
  String selectedFilter = 'All stays';

  final filters = ['All stays', 'Upcoming', 'Current stay', 'Past stays', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => loading = true);
    try {
      final token = AccountStore.instance.token;
      if (token == null) {
        setState(() => bookings = []);
        return;
      }

      final [bookingsData, roomsData] = await Future.wait([
        AuthService.getReservations(token),
        AuthService.getRooms(),
      ]);

      final roomsList = roomsData.map((r) => r as Map<String, dynamic>).toList();
      final bookingsList = bookingsData.map((b) => b as Map<String, dynamic>).toList();

      // Attach room details to each booking
      final enrichedBookings = bookingsList.map((booking) {
        final roomId = booking['roomId'] as String?;
        final room = roomsList.firstWhere(
          (r) => r['id'] == roomId,
          orElse: () => <String, dynamic>{},
        );
        return {...booking, 'room': room};
      }).toList();

      setState(() {
        bookings = enrichedBookings;
        rooms = roomsList;
      });
    } catch (e) {
      showAppMessage(context, 'Failed to load reservations: $e');
      setState(() => bookings = []);
    } finally {
      setState(() => loading = false);
    }
  }

  List<Map<String, dynamic>> get filteredBookings {
    return bookings.where((booking) {
      final status = booking['status'] as String;
      switch (selectedFilter) {
        case 'All stays':
          return true;
        case 'Upcoming':
          return ['Pending', 'Confirmed'].contains(status);
        case 'Current stay':
          return status == 'Checked-in';
        case 'Past stays':
          return status == 'Checked-out';
        case 'Cancelled':
          return status == 'Cancelled';
        default:
          return true;
      }
    }).toList();
  }

  int _getFilterCount(String filter) {
    return bookings.where((booking) {
      final status = booking['status'] as String;
      switch (filter) {
        case 'All stays':
          return true;
        case 'Upcoming':
          return ['Pending', 'Confirmed'].contains(status);
        case 'Current stay':
          return status == 'Checked-in';
        case 'Past stays':
          return status == 'Checked-out';
        case 'Cancelled':
          return status == 'Cancelled';
        default:
          return true;
      }
    }).length;
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.month}/${date.day}/${date.year}';
  }

  String _getRoomType(String? type) {
    if (type == 'Suite') return 'The Aureline Suite';
    return '$type retreat';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return const Color(0xFF4CAF50);
      case 'Pending':
        return const Color(0xFFFF9800);
      case 'Checked-in':
        return const Color(0xFF2196F3);
      case 'Checked-out':
        return const Color(0xFF9E9E9E);
      case 'Cancelled':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = AccountStore.instance.name ?? 'Guest';

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeHeader(name: name),
                    _BannerSection(),
                    _FilterTabs(),
                    if (filteredBookings.isEmpty)
                      _EmptyState()
                    else
                      _BookingList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _WelcomeHeader({required String name}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YOUR AURELINE JOURNAL', style: TextStyle(fontSize: 10, letterSpacing: 1.8, color: muted)),
          const SizedBox(height: 8),
          Text('Welcome back, ${name.split(' ')[0]}.', style: GoogleFonts.playfairDisplay(fontSize: 28, color: ink, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Your escapes, your memories, your next chapter.', style: TextStyle(fontSize: 14, color: muted)),
        ],
      ),
    );
  }

  Widget _BannerSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: forest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('THERE\'S ALWAYS ANOTHER STORY', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Color(0xFFD4DCC8))),
          const SizedBox(height: 8),
          Text(
            'Somewhere lovely to look forward to.',
            style: GoogleFonts.playfairDisplay(fontSize: 20, color: Colors.white, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _FilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;
            final count = _getFilterCount(filter);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(filter),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.3) : forest.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : forest,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => selectedFilter = filter);
                },
                backgroundColor: Colors.white,
                selectedColor: forest,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : muted,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: isSelected ? forest : border),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _EmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.bed_outlined, size: 64, color: muted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No stays yet',
            style: GoogleFonts.playfairDisplay(fontSize: 24, color: ink),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Aureline journey begins with a single reservation.',
            style: TextStyle(color: muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _BookingList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: filteredBookings.map((booking) => _BookingCard(booking)).toList(),
      ),
    );
  }

  Widget _BookingCard(Map<String, dynamic> booking) {
    final room = booking['room'] as Map<String, dynamic>?;
    final status = booking['status'] as String;
    final checkIn = booking['checkIn'] as String;
    final checkOut = booking['checkOut'] as String;
    final roomId = booking['roomId'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room != null && room['image'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  room['image'] as String,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: paleGreen,
                      child: const Icon(Icons.bed, size: 48, color: muted),
                    );
                  },
                ),
              ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking['id'] as String? ?? 'Unknown',
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getRoomType(room?['type'] as String?),
                  style: GoogleFonts.playfairDisplay(fontSize: 18, color: ink),
                ),
                if (roomId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Room ID: $roomId',
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: muted),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDate(checkIn)} – ${_formatDate(checkOut)}',
                      style: const TextStyle(fontSize: 13, color: muted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 14, color: muted),
                    const SizedBox(width: 4),
                    Text(
                      '${booking['guests']} guest${booking['guests'] == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 13, color: muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    final room = booking['room'] as Map<String, dynamic>?;
    final status = booking['status'] as String;
    final checkIn = booking['checkIn'] as String;
    final checkOut = booking['checkOut'] as String;
    final rate = booking['rate'] as num?;
    final createdAt = booking['createdAt'] as String?;

    final nights = _calculateNights(checkIn, checkOut);
    final total = rate != null ? rate * nights : 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reservation ${booking['id'] as String? ?? ''}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Guest info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: forest,
                    child: Text(
                      AccountStore.instance.name?.isNotEmpty == true
                          ? AccountStore.instance.name![0].toUpperCase()
                          : 'G',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AccountStore.instance.name ?? 'Guest',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          AccountStore.instance.email ?? '',
                          style: const TextStyle(fontSize: 12, color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              // Details grid
              _DetailRow('Room', '${room?['number'] ?? 'N/A'} · ${room?['type'] ?? 'Room'}'),
              _DetailRow('Guests', '${booking['guests']}'),
              _DetailRow('Check-in', _formatDate(checkIn)),
              _DetailRow('Check-out', _formatDate(checkOut)),
              _DetailRow('Length of stay', '$nights night${nights == 1 ? '' : 's'}'),
              if (rate != null) _DetailRow('Rate per night', '₱${rate.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total amount', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '₱${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: forest),
                  ),
                ],
              ),
              if (createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Created ${_formatDate(createdAt)}',
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
              ],
              if (status == 'Checked-in') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'You are currently checked in. Please settle your balance before checkout.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF2196F3)),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (['Pending', 'Confirmed'].contains(status))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelReservation(booking);
              },
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFF44336)),
              child: const Text('Cancel reservation'),
            ),
        ],
      ),
    );
  }

  int _calculateNights(String checkIn, String checkOut) {
    try {
      final start = DateTime.parse(checkIn);
      final end = DateTime.parse(checkOut);
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }

  Widget _DetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: muted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _cancelReservation(Map<String, dynamic> booking) async {
    try {
      final token = AccountStore.instance.token;
      if (token == null) {
        showAppMessage(context, 'You must be logged in');
        return;
      }

      await AuthService.updateReservationStatus(
        bookingId: booking['id'] as String,
        status: 'Cancelled',
        token: token,
      );

      if (mounted) {
        showAppMessage(context, 'Reservation cancelled successfully');
        _loadBookings();
      }
    } catch (e) {
      if (mounted) {
        showAppMessage(context, 'Failed to cancel reservation: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }
  }
}
