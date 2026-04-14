import 'package:flutter/material.dart';
import '../../widgets/synora_header.dart';
import '../../widgets/design_system.dart';
import 'vendor_messages.dart';

class VendorBookingsScreen extends StatefulWidget {
  const VendorBookingsScreen({super.key});

  @override
  State<VendorBookingsScreen> createState() => _VendorBookingsScreenState();
}

class _VendorBookingsScreenState extends State<VendorBookingsScreen> {
  final List<Map<String, String>> _bookings = [
    {'name': 'Rahul Sharma', 'type': 'Wedding', 'date': 'Dec 22, 2023', 'status': 'Pending', 'location': 'Grand Hall, Mumbai'},
    {'name': 'Priya Singh', 'type': 'Birthday', 'date': 'Dec 24, 2023', 'status': 'Confirmed', 'location': 'Blue Lotus Resort'},
    {'name': 'Amit Patel', 'type': 'Corporate', 'date': 'Dec 28, 2023', 'status': 'Pending', 'location': 'Convention Center'},
    {'name': 'Sangeeta Roy', 'type': 'Anniversary', 'date': 'Jan 05, 2024', 'status': 'Confirmed', 'location': 'Sea View Hotel'},
    {'name': 'Vikram Malhotra', 'type': 'Sangeet', 'date': 'Jan 10, 2024', 'status': 'Rejected', 'location': 'Green Gardens'},
  ];

  void _updateBookingStatus(int index, String newStatus) {
    setState(() {
      _bookings[index]['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking ${newStatus}!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Bookings',
            subtitle: 'Manage your event requests',
          ),
          Expanded(
            child: ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final b = _bookings[index];
        final String status = b['status']!;
        Color statusColor;
        switch (status) {
          case 'Confirmed': statusColor = Colors.green; break;
          case 'Rejected': statusColor = Colors.red; break;
          default: statusColor = Colors.orange;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: SynoraAvatar(name: b['name'], size: 45),
                  title: Text(b['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${b['type']} • ${b['date']}', style: const TextStyle(fontSize: 12)),
                      Text(b['location']!, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0.5)),
                  ),
                ),
                const Divider(height: 24, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (status == 'Pending') ...[
                        TextButton(
                          onPressed: () => _updateBookingStatus(index, 'Rejected'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _updateBookingStatus(index, 'Confirmed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      if (status != 'Pending')
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailScreen(booking: b)));
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: const Text('View Details'),
                          style: TextButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ),
],
),
);
}

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class BookingDetailScreen extends StatelessWidget {
  final Map<String, String> booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            ),
            const SizedBox(height: 24),
            _buildDetailItem('Customer Name', booking['name']!),
            _buildDetailItem('Event Type', booking['type']!),
            _buildDetailItem('Date', booking['date']!),
            _buildDetailItem('Location', booking['location']!),
            _buildDetailItem('Estimated Budget', '₹50,000'),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen(name: booking['name']!, phone: '+91 98765 43210')),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
