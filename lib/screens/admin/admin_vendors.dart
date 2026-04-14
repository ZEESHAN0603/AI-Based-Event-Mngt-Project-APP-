import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/vendor.dart';
import 'admin_vendor_detail.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';

class AdminVendorsScreen extends StatefulWidget {
  const AdminVendorsScreen({super.key});

  @override
  State<AdminVendorsScreen> createState() => _AdminVendorsScreenState();
}

class _AdminVendorsScreenState extends State<AdminVendorsScreen> {
  String _searchQuery = '';
  VendorStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final vendors = vendorProvider.vendors.where((v) {
      final matchesSearch = v.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == null || v.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Vendor Management',
            subtitle: 'Monitor and approve platform vendors',
          ),
          PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  GlassCard(
                    padding: EdgeInsets.zero,
                    opacity: 0.1,
                    child: TextField(
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search vendors...',
                        hintStyle: const TextStyle(),
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _statusChip(null, 'All'),
                        _statusChip(VendorStatus.pending, 'Pending'),
                        _statusChip(VendorStatus.approved, 'Approved'),
                        _statusChip(VendorStatus.rejected, 'Rejected'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: vendors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business_rounded, size: 64),
                        const SizedBox(height: 16),
                        const Text('No vendors found', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: vendors.length,
                      itemBuilder: (context, index) {
                        final vendor = vendors[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildVendorCard(context, vendor, vendorProvider),
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

  Widget _statusChip(VendorStatus? status, String label) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: AnimatedPressable(
        onTap: () => setState(() => _statusFilter = isSelected ? null : status),
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

  Widget _buildVendorCard(BuildContext context, Vendor vendor, VendorProvider provider) {
    Color statusColor;
    switch (vendor.status) {
      case VendorStatus.approved: statusColor = Colors.teal; break;
      case VendorStatus.pending: statusColor = Colors.orange; break;
      case VendorStatus.rejected: statusColor = Colors.red; break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SynoraAvatar(name: vendor.name, size: 50),
              title: Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${vendor.category.name.toUpperCase()} • ${vendor.location}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      vendor.status.name.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: statusColor),
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminVendorDetailScreen(vendor: vendor)));
              },
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (vendor.status != VendorStatus.approved)
                  _actionButton('Approve', Icons.check_circle_outline, Colors.teal, () => provider.updateVendorStatus(vendor.id, VendorStatus.approved)),
                if (vendor.status != VendorStatus.rejected)
                  _actionButton('Reject', Icons.close_rounded, Colors.red, () => provider.updateVendorStatus(vendor.id, VendorStatus.rejected)),
                _actionButton('Details', Icons.visibility_outlined, Theme.of(context).primaryColor, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminVendorDetailScreen(vendor: vendor)));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: AnimatedPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
