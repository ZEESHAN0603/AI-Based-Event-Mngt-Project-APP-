import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/vendor.dart';
import '../../providers/event_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/shortlist_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/design_system.dart';
import 'organizer_messages.dart';

class VendorDetailScreen extends StatefulWidget {
  final Vendor vendor;
  const VendorDetailScreen({super.key, required this.vendor});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventId = context.read<EventProvider>().selectedEventId;
      if (eventId != null) {
        context.read<ShortlistProvider>().fetchShortlist(eventId);
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _toggleShortlist(String? eventId) async {
    if (eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an event first')));
      return;
    }
    final provider = context.read<ShortlistProvider>();
    final isShortlisted = provider.isShortlisted(widget.vendor.id);
    bool success;
    if (isShortlisted) {
      final id = provider.getShortlistId(widget.vendor.id);
      success = id != null
          ? await provider.removeFromShortlist(eventId, id)
          : false;
    } else {
      success = await provider.addToShortlist(eventId, widget.vendor.id);
    }
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isShortlisted ? 'Removed from shortlist' : 'Added to shortlist ✓'),
        backgroundColor: isShortlisted ? null : AppColors.success,
      ));
    }
  }

  Future<void> _requestBooking(String eventId) async {
    setState(() => _isBooking = true);
    final success = await context.read<BookingProvider>().createBooking({
      'event_id': eventId,
      'vendor_id': widget.vendor.id,
      'total_amount': widget.vendor.basePriceMin,
      'notes': 'Requested via EventLink App',
    });
    if (!mounted) return;
    setState(() => _isBooking = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Booking request sent! ✓' : 'Failed to send request'),
      backgroundColor: success ? AppColors.success : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final eventId = context.watch<EventProvider>().selectedEventId;
    final isShortlisted = context.watch<ShortlistProvider>().isShortlisted(widget.vendor.id);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildSliverAppBar(context)],
        body: Column(
          children: [
            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _buildAboutTab(context),
                  _buildPortfolioTab(context),
                  _buildReviewsTab(context),
                ],
              ),
            ),
            _buildCTAs(context, eventId, isShortlisted),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.vendor.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(gradient: AppColors.gradient),
                child: const Center(
                  child: Icon(Icons.storefront_rounded,
                      size: 80, color: Colors.white30),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vendor.businessName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip(Icons.star_rounded, widget.vendor.rating.toStringAsFixed(1),
                          const Color(0xFFFBBF24)),
                      _chip(Icons.location_on_rounded, widget.vendor.location, Colors.white),
                      _chip(Icons.currency_rupee_rounded,
                          '${_fmt(widget.vendor.basePriceMin)}–${_fmt(widget.vendor.basePriceMax)}',
                          AppColors.primary),
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

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surface
          : Colors.white,
      child: TabBar(
        controller: _tabs,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Portfolio'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          const Text('About Vendor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.vendor.description.isNotEmpty
                  ? widget.vendor.description
                  : 'No description provided.',
              style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 20),
          // Details grid
          const Text('Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow(Icons.location_on_rounded, 'Location', widget.vendor.location),
                const Divider(height: 20),
                _detailRow(Icons.star_rounded, 'Rating',
                    '${widget.vendor.rating.toStringAsFixed(1)} / 5.0 (${widget.vendor.totalReviews} reviews)'),
                const Divider(height: 20),
                _detailRow(Icons.currency_rupee_rounded, 'Price Range',
                    '₹${_fmt(widget.vendor.basePriceMin)} – ₹${_fmt(widget.vendor.basePriceMax)}'),
                const Divider(height: 20),
                _detailRow(Icons.verified_rounded, 'Status', 'Approved & Verified'),
              ],
            ),
          ),
          // Contact
          const SizedBox(height: 20),
          const Text('Contact',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => OrganizerChatScreen(
                            name: widget.vendor.businessName,
                            phone: '+91 98765 43210')),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Column(
                    children: [
                      Icon(Icons.message_rounded, color: AppColors.primary),
                      SizedBox(height: 6),
                      Text('Message',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppCard(
                  onTap: () => _showCallDialog(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Column(
                    children: [
                      Icon(Icons.call_rounded, color: AppColors.success),
                      SizedBox(height: 6),
                      Text('Call',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab(BuildContext context) {
    if (widget.vendor.portfolioUrl == null ||
        widget.vendor.portfolioUrl!.isEmpty) {
      return const AppEmptyState(
        icon: Icons.photo_library_rounded,
        title: 'No Portfolio',
        subtitle: 'This vendor hasn\'t added a portfolio yet.',
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.open_in_new_rounded,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Portfolio Available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              widget.vendor.portfolioUrl!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.primary, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            AppGradientButton(
              label: 'Open Portfolio',
              icon: Icons.launch_rounded,
              onPressed: () async {
                final uri = Uri.parse(widget.vendor.portfolioUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    return AppEmptyState(
      icon: Icons.rate_review_rounded,
      title: 'No Reviews Yet',
      subtitle: widget.vendor.totalReviews == 0
          ? 'Be the first to review this vendor.'
          : '${widget.vendor.totalReviews} reviews coming soon.',
    );
  }

  Widget _buildCTAs(
      BuildContext context, String? eventId, bool isShortlisted) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surface
            : Colors.white,
        border: Border(
          top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shortlist button
          Expanded(
            child: AnimatedPressable(
              onTap: () => _toggleShortlist(eventId),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isShortlisted
                      ? AppColors.success.withValues(alpha: 0.1)
                      : null,
                  border: Border.all(
                    color: isShortlisted
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isShortlisted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                      color:
                          isShortlisted ? AppColors.success : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isShortlisted ? 'Shortlisted' : 'Shortlist',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isShortlisted
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Book button
          Expanded(
            child: AppGradientButton(
              label: 'Book Now',
              icon: Icons.calendar_today_rounded,
              loading: _isBooking,
              width: double.infinity,
              onPressed: eventId == null
                  ? null
                  : () => _requestBooking(eventId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
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
      ],
    );
  }

  void _showCallDialog(BuildContext context) {
    const phone = '+91 98765 43210';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.vendor.businessName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(phone),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: phone));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone number copied')));
            },
            child: const Text('Copy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri(scheme: 'tel', path: phone);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
              Navigator.pop(ctx);
            },
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  String _fmt(double price) {
    if (price >= 100000) return '${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return NumberFormat('#,###').format(price.toInt());
  }
}
