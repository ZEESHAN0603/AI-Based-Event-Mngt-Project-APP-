import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/shortlist_provider.dart';
import '../../providers/event_provider.dart';
import '../../models/event.dart';
import '../../models/vendor.dart';
import '../../theme/app_theme.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';
import 'vendor_details.dart';

class VendorListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Event? event;

  const VendorListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.event,
  });

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().fetchVendors(categoryId: widget.categoryId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Vendor> _filtered(List<Vendor> vendors) {
    if (_search.isEmpty) return vendors;
    final q = _search.toLowerCase();
    return vendors.where((v) =>
        v.businessName.toLowerCase().contains(q) ||
        v.location.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final vendors = _filtered(vendorProvider.vendors);

    return Scaffold(
      body: Column(
        children: [
          SynoraHeader(
            title: widget.categoryName,
            subtitle: 'Expert professionals for your event',
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // List
          Expanded(
            child: vendorProvider.isLoading
                ? _buildSkeleton()
                : vendors.isEmpty
                    ? AppEmptyState(
                        icon: Icons.storefront_rounded,
                        title: _search.isNotEmpty
                            ? 'No Vendors Found'
                            : 'No Vendors in Category',
                        subtitle: _search.isNotEmpty
                            ? 'Try a different search term.'
                            : 'No vendors are available in this category yet.',
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: vendors.length,
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 40,
                                child: FadeInAnimation(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _VendorCard(vendor: vendors[index]),
                                  ),
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

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            SkeletonLoader(
                width: double.infinity, height: 180, borderRadius: 20),
            const SizedBox(height: 8),
            const SkeletonLoader(width: double.infinity, height: 90, borderRadius: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vendor Card
// ─────────────────────────────────────────────────────────────────────────────

class _VendorCard extends StatelessWidget {
  final Vendor vendor;
  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final shortlistProvider = context.watch<ShortlistProvider>();
    final eventId = context.read<EventProvider>().selectedEventId;
    final isShortlisted = shortlistProvider.isShortlisted(vendor.id);

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VendorDetailScreen(vendor: vendor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ───────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    vendor.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _imagePlaceholder(),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.75),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 15, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 4),
                          Text(
                            vendor.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${vendor.totalReviews})',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹${_formatPrice(vendor.basePriceMin)}+',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Details ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vendor.businessName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        vendor.location,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (vendor.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    vendor.description,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  VendorDetailScreen(vendor: vendor)),
                        ),
                        icon: const Icon(Icons.visibility_rounded, size: 14),
                        label: const Text('View Details',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (eventId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Select an event first')),
                            );
                            return;
                          }
                          final provider =
                              context.read<ShortlistProvider>();
                          if (isShortlisted) {
                            final id =
                                provider.getShortlistId(vendor.id);
                            if (id != null) {
                              await provider.removeFromShortlist(
                                  eventId, id);
                            }
                          } else {
                            await provider.addToShortlist(
                                eventId, vendor.id);
                          }
                        },
                        icon: Icon(
                          isShortlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 14,
                        ),
                        label: Text(
                          isShortlisted ? 'Shortlisted' : 'Shortlist',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isShortlisted
                              ? AppColors.success
                              : AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Icon(Icons.storefront_rounded,
            size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toStringAsFixed(0);
  }
}
