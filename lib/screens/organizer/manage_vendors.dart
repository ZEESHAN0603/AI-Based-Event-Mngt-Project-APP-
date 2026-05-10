import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/shortlist_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../widgets/synora_header.dart';
import '../../widgets/design_system.dart';
import '../../models/vendor.dart';
import 'vendor_details.dart';

class ManageVendorsScreen extends StatefulWidget {
  final Event event;

  const ManageVendorsScreen({super.key, required this.event});

  @override
  State<ManageVendorsScreen> createState() => _ManageVendorsScreenState();
}

class _ManageVendorsScreenState extends State<ManageVendorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShortlistProvider>().fetchShortlist(widget.event.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SynoraHeader(
            title: 'Event Vendors',
            subtitle: 'Shortlisted for ${widget.event.name}',
          ),
          Expanded(
            child: Consumer<ShortlistProvider>(
              builder: (context, shortlistProvider, child) {
                if (shortlistProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = shortlistProvider.shortlistedItems;
                if (items.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final vendorData = item['vendor'];
                    
                    // The backend might return full vendor object or just id
                    // If it's a map, we can parse it
                    if (vendorData is Map<String, dynamic>) {
                      final vendor = Vendor.fromJson(vendorData);
                      return _buildVendorTile(context, vendor, item['id']);
                    }

                    return ListTile(
                      title: Text('Vendor ID: ${item['vendor_id']}'),
                      subtitle: const Text('Details unavailable'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No vendors shortlisted yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Find Vendors'),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorTile(BuildContext context, Vendor vendor, String shortlistId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: SynoraAvatar(name: vendor.businessName),
          title: Text(vendor.businessName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('₹${vendor.basePriceMin.toInt()} • ${vendor.location}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              context.read<ShortlistProvider>().removeFromShortlist(widget.event.id, shortlistId);
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VendorDetailScreen(vendor: vendor)),
            );
          },
        ),
      ),
    );
  }
}
