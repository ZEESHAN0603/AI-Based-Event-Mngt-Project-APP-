import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/vendor.dart';
import '../../providers/shortlist_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/design_system.dart';
import 'vendor_details.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShortlistProvider>().fetchShortlist(widget.event.id);
    });
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'wedding': return const Color(0xFFEC4899);
      case 'birthday': return const Color(0xFFF59E0B);
      case 'corporate': return const Color(0xFF0EA5E9);
      default: return AppColors.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'wedding': return Icons.favorite_rounded;
      case 'birthday': return Icons.cake_rounded;
      case 'corporate': return Icons.business_center_rounded;
      default: return Icons.celebration_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(widget.event.type);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Event Hero Card ───────────────────────────────────────
            AppCard(
              gradient: LinearGradient(
                colors: [typeColor, typeColor.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_typeIcon(widget.event.type),
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.event.type,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Info Cards ────────────────────────────────────────────
            const Text('Event Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow(Icons.calendar_today_rounded, 'Date',
                      DateFormat('EEEE, dd MMMM yyyy').format(widget.event.date),
                      AppColors.primary),
                  const Divider(height: 20),
                  _infoRow(Icons.location_on_rounded, 'Location',
                      widget.event.location, AppColors.secondary),
                  const Divider(height: 20),
                  _infoRow(
                      Icons.account_balance_wallet_rounded,
                      'Budget',
                      '₹${NumberFormat('#,##,###').format(widget.event.totalBudget.toInt())}',
                      AppColors.warning),
                  if (widget.event.numGuests != null) ...[
                    const Divider(height: 20),
                    _infoRow(Icons.people_rounded, 'Guests',
                        '${widget.event.numGuests} guests', AppColors.success),
                  ],
                  if (widget.event.description != null &&
                      widget.event.description!.isNotEmpty) ...[
                    const Divider(height: 20),
                    _infoRow(Icons.description_rounded, 'Description',
                        widget.event.description!, Colors.grey),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── Shortlisted Vendors ───────────────────────────────────
            const Text('Shortlisted Vendors',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Consumer<ShortlistProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Column(
                    children: List.generate(
                      2,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SkeletonLoader(
                            width: double.infinity,
                            height: 90,
                            borderRadius: 20),
                      ),
                    ),
                  );
                }
                if (provider.shortlistedItems.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: 'No Vendors Shortlisted',
                    subtitle: 'Browse vendors and shortlist them to your event.',
                  );
                }
                return Column(
                  children: provider.shortlistedItems.map((item) {
                    final vendorData =
                        item['vendor'] as Map<String, dynamic>?;
                    if (vendorData == null || vendorData.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final vendor = Vendor.fromJson(vendorData);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ShortlistedVendorCard(
                        vendor: vendor,
                        onRemove: () => provider.removeFromShortlist(
                          widget.event.id,
                          item['id']?.toString() ?? '',
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shortlisted Vendor Card
// ─────────────────────────────────────────────────────────────────────────────

class _ShortlistedVendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback onRemove;

  const _ShortlistedVendorCard({required this.vendor, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VendorDetailScreen(vendor: vendor)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Avatar
          SynoraAvatar(name: vendor.businessName, size: 48),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.businessName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 12, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 3),
                    Text(vendor.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    Icon(Icons.location_on_rounded,
                        size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        vendor.location,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${_fmt(vendor.basePriceMin)} – ₹${_fmt(vendor.basePriceMax)}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Remove
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded,
                color: AppColors.error, size: 22),
            onPressed: onRemove,
            tooltip: 'Remove',
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
