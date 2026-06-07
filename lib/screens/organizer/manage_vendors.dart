import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/vendor.dart';
import '../../providers/shortlist_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';
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
            title: 'Shortlisted Vendors',
            subtitle: 'For ${widget.event.name}',
          ),
          Expanded(
            child: Consumer<ShortlistProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return _buildSkeleton();

                final items = provider.shortlistedItems;
                if (items.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'No Vendors Shortlisted',
                    subtitle:
                        'Browse vendors and add them to this event\'s shortlist.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final vendorData = item['vendor'] as Map<String, dynamic>?;

                    if (vendorData == null || vendorData.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final vendor = Vendor.fromJson(vendorData);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _VendorShortlistCard(
                        vendor: vendor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => VendorDetailScreen(vendor: vendor)),
                        ),
                        onRemove: () => provider.removeFromShortlist(
                          widget.event.id,
                          item['id']?.toString() ?? '',
                        ),
                      ),
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

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SkeletonLoader(width: double.infinity, height: 90, borderRadius: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shortlist Card
// ─────────────────────────────────────────────────────────────────────────────

class _VendorShortlistCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _VendorShortlistCard({
    required this.vendor,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Avatar
          SynoraAvatar(name: vendor.businessName, size: 52),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.businessName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      size: 13, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 3),
                  Text(
                    vendor.rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      vendor.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 5),
                Text(
                  '₹${_fmt(vendor.basePriceMin)} – ₹${_fmt(vendor.basePriceMax)}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          // Remove button
          Column(
            children: [
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double price) {
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toStringAsFixed(0);
  }
}
