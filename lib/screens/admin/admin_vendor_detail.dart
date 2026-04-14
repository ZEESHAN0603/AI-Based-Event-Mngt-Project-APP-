import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vendor.dart';
import '../../providers/vendor_provider.dart';

class AdminVendorDetailScreen extends StatelessWidget {
  final Vendor vendor;
  const AdminVendorDetailScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final currentVendor = vendorProvider.vendors.firstWhere((v) => v.id == vendor.id);

    return Scaffold(
      appBar: AppBar(title: Text(currentVendor.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(currentVendor.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 24),
            _buildHeader(currentVendor),
            const SizedBox(height: 24),
            _buildSectionTitle('Description'),
            const Text(
              'A premium service provider with over 10 years of experience in the industry. Known for attention to detail and exceptional customer service.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Pricing & Information'),
            _infoRow(Icons.monetization_on, 'Base Price', '₹${currentVendor.price}'),
            _infoRow(Icons.location_on, 'Location', currentVendor.location),
            _infoRow(Icons.star, 'Rating', '${currentVendor.rating} / 5.0'),
            _infoRow(Icons.work, 'Experience', '12+ Years'),
            const SizedBox(height: 24),
            _buildSectionTitle('Portfolio Preview'),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (context, i) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network('https://images.unsplash.com/photo-1511795409834-ef04bbd61622', width: 100, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildActionButtons(context, vendorProvider, currentVendor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Vendor v) {
    Color statusColor;
    switch (v.status) {
      case VendorStatus.approved: statusColor = Colors.green; break;
      case VendorStatus.pending: statusColor = Colors.orange; break;
      case VendorStatus.rejected: statusColor = Colors.red; break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(v.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                v.status.name.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: statusColor),
              ),
            ),
          ],
        ),
        Text(v.category.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, VendorProvider provider, Vendor v) {
    return Row(
      children: [
        if (v.status != VendorStatus.approved)
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Approve'),
              onPressed: () {
                provider.updateVendorStatus(v.id, VendorStatus.approved);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vendor Approved')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        if (v.status != VendorStatus.approved && v.status != VendorStatus.rejected) const SizedBox(width: 12),
        if (v.status != VendorStatus.rejected)
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Reject'),
              onPressed: () {
                provider.updateVendorStatus(v.id, VendorStatus.rejected);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vendor Rejected')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
      ],
    );
  }
}
