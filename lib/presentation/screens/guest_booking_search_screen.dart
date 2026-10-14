import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/account_store.dart';
import '../common/widgets.dart';

class GuestBookingSearchScreen extends StatefulWidget {
  const GuestBookingSearchScreen({super.key});
  @override
  State<GuestBookingSearchScreen> createState() => _GuestBookingSearchScreenState();
}

class _GuestBookingSearchScreenState extends State<GuestBookingSearchScreen> {
  DateTime? checkIn;
  DateTime? checkOut;
  int guests = 2;
  List<Map<String, dynamic>> availableRooms = [];
  bool loading = false;
  String? error;
  String selectedType = 'All rooms';
  final types = ['All rooms', 'Single', 'Double', 'Deluxe', 'Suite'];

  DateTime get today => DateTime.now();
  DateTime get minCheckOut => checkIn != null ? checkIn!.add(const Duration(days: 1)) : today;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool get canSearch => checkIn != null && checkOut != null && checkOut!.isAfter(checkIn!);

  Future<void> _searchRooms() async {
    if (!canSearch) {
      setState(() => error = 'Choose valid future dates with check-out after check-in.');
      return;
    }

    setState(() => loading = true);
    error = null;

    try {
      final token = AccountStore.instance.token;
      if (token == null) {
        throw Exception('You must be logged in to book a room');
      }

      final rooms = await AuthService.searchRooms(
        checkIn: _formatDate(checkIn),
        checkOut: _formatDate(checkOut),
        guests: guests,
        type: selectedType == 'All rooms' ? null : selectedType,
        token: token,
      );

      setState(() => availableRooms = List<Map<String, dynamic>>.from(rooms));
    } catch (e) {
      setState(() => error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => loading = false);
    }
  }

  void _selectRoom(Map<String, dynamic> room) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              _SearchHero(),
              _SearchForm(),
              if (availableRooms.isNotEmpty) _ResultsHeader(),
              if (availableRooms.isNotEmpty) _RoomGrid(),
              if (loading) const Center(child: CircularProgressIndicator()),
              if (error != null) _ErrorBanner(),
              if (!loading && availableRooms.isEmpty && canSearch) _EmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _Header() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MAKE YOURSELF AT HOME', style: TextStyle(fontSize: 10, letterSpacing: 1.8, color: muted)),
          const SizedBox(height: 8),
          Text('Find your kind of quiet.', style: GoogleFonts.playfairDisplay(fontSize: 28, color: ink, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('A beautiful room. A slower morning. A stay to remember.', style: TextStyle(fontSize: 14, color: muted)),
        ],
      ),
    );
  }

  Widget _SearchHero() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: forest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ROOM TO REST. SPACE TO RECONNECT.', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Color(0xFFD4DCC8))),
          const SizedBox(height: 12),
          Text(
            'Your next chapter begins here.',
            style: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _SearchForm() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateField(
            label: 'Check-in',
            date: checkIn,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: checkIn ?? today,
                firstDate: today,
                lastDate: DateTime(today.year + 2),
              );
              if (picked != null) {
                setState(() => checkIn = picked);
                // If check-out is before new check-in, update it
                if (checkOut != null && checkOut!.isBefore(picked)) {
                  setState(() => checkOut = picked.add(const Duration(days: 1)));
                }
              }
            },
          ),
          const SizedBox(height: 16),
          _DateField(
            label: 'Check-out',
            date: checkOut,
            enabled: checkIn != null,
            onTap: () async {
              if (checkIn == null) {
                showAppMessage(context, 'Please select check-in date first');
                return;
              }
              final picked = await showDatePicker(
                context: context,
                initialDate: checkOut ?? checkIn!.add(const Duration(days: 1)),
                firstDate: checkIn!.add(const Duration(days: 1)),
                lastDate: DateTime(today.year + 2),
              );
              if (picked != null) {
                setState(() => checkOut = picked);
              }
            },
          ),
          const SizedBox(height: 16),
          _GuestField(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : _searchRooms,
              icon: const Icon(Icons.search),
              label: const Text('Find available rooms'),
              style: FilledButton.styleFrom(
                backgroundColor: forest,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _DateField({required String label, required DateTime? date, required VoidCallback onTap, bool enabled = true}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: enabled ? border : border.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
              color: enabled ? Colors.white : Colors.grey.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: enabled ? muted : muted.withOpacity(0.5)),
                const SizedBox(width: 12),
                Text(
                  _formatDate(date) ?? 'Select date',
                  style: TextStyle(color: enabled ? (date != null ? ink : muted) : muted.withOpacity(0.5)),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: enabled ? muted : muted.withOpacity(0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _GuestField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Guests', style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: guests,
              isExpanded: true,
              items: [1, 2, 3, 4].map((n) {
                return DropdownMenuItem<int>(
                  value: n,
                  child: Text('$n guest${n > 1 ? 's' : ''}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => guests = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _ResultsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${availableRooms.length} rooms for your stay',
            style: const TextStyle(fontSize: 14, color: ink, fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<String>(
              value: selectedType,
              underline: const SizedBox(),
              isDense: true,
              items: types.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedType = value);
                  _searchRooms();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _RoomGrid() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: availableRooms.map((room) => _RoomCard(room)).toList(),
      ),
    );
  }

  Widget _RoomCard(Map<String, dynamic> room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _selectRoom(room),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (room['image'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  room['image'] as String,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
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
                      room['type'] as String? ?? 'Room',
                      style: GoogleFonts.playfairDisplay(fontSize: 18, color: ink),
                    ),
                    Text(
                      '₱${room['price']}/night',
                      style: const TextStyle(fontSize: 14, color: forest, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Capacity: ${room['capacity']} guest${room['capacity'] == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 12, color: muted),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _selectRoom(room),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Select this room'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: forest,
                      side: const BorderSide(color: forest),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _ErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF44336).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF44336)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFF44336)),
          const SizedBox(width: 12),
          Expanded(child: Text(error!, style: const TextStyle(color: Color(0xFFF44336)))),
        ],
      ),
    );
  }

  Widget _EmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: muted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'A different date, perhaps?',
            style: GoogleFonts.playfairDisplay(fontSize: 24, color: ink),
          ),
          const SizedBox(height: 8),
          const Text(
            'No rooms are available for this selection. Try another date or guest count.',
            style: TextStyle(color: muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
