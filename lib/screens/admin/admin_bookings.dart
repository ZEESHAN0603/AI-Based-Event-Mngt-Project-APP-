import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';
import 'package:intl/intl.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  AdminBookingStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final bookings = adminProvider.bookings.where((b) {
      return _filter == null || b.status == _filter;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'All Bookings',
            subtitle: 'Monitor system-wide event reservations',
          ),
          PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _filterChip(null, 'All'),
                  _filterChip(AdminBookingStatus.pending, 'Pending'),
                  _filterChip(AdminBookingStatus.confirmed, 'Confirmed'),
                  _filterChip(AdminBookingStatus.rejected, 'Rejected'),
                ],
              ),
            ),
          ),
          Expanded(
            child: bookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_rounded, size: 64),
                        const SizedBox(height: 16),
                        const Text('No bookings found', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildBookingCard(context, booking, adminProvider),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(AdminBookingStatus? status, String label) {
    final isSelected = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: AnimatedPressable(
        onTap: () => setState(() => _filter = isSelected ? null : status),
        child: GlassCard(
          opacity: isSelected ? 0.2 : 0.05,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: BorderRadius.circular(20),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, AdminBooking booking, AdminProvider provider) {
    Color statusColor;
    switch (booking.status) {
      case AdminBookingStatus.confirmed: statusColor = Colors.teal; break;
      case AdminBookingStatus.pending: statusColor = Colors.orange; break;
      case AdminBookingStatus.rejected: statusColor = Colors.red; break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.eventName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.name.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _rowInfo('Organizer', booking.organizerName, Icons.person_outline_rounded),
            const SizedBox(height: 8),
            _rowInfo('Vendor', booking.vendorName, Icons.business_outlined),
            const SizedBox(height: 8),
            _rowInfo('Date', DateFormat('MMM dd, yyyy').format(booking.date), Icons.calendar_today_rounded),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (booking.status != AdminBookingStatus.confirmed)
                  _actionButton('Confirm', Icons.check_circle_outline, Colors.teal, () => provider.updateBookingStatus(booking.id, AdminBookingStatus.confirmed)),
                if (booking.status != AdminBookingStatus.rejected)
                  _actionButton('Reject', Icons.close_rounded, Colors.red, () => provider.updateBookingStatus(booking.id, AdminBookingStatus.rejected)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: AnimatedPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
