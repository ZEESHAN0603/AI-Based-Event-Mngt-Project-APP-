import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/budget_provider.dart';
import '../../models/vendor.dart';
import 'organizer_messages.dart';
import '../../widgets/design_system.dart';

class VendorDetailScreen extends StatelessWidget {
  final Vendor vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final eventId = context.watch<EventProvider>().selectedEventId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: AnimationLimiter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildVendorHeader(context),
                      const SizedBox(height: 32),
                      _buildDescription(context),
                      const SizedBox(height: 32),
                      _buildServices(context),
                      const SizedBox(height: 32),
                      _buildActions(context, eventId),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            vendor.imageUrl.isNotEmpty
                ? Image.network(vendor.imageUrl, fit: BoxFit.cover)
                : Container(
                    child: const Icon(Icons.business, size: 100),
                  ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.name,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vendor.category.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 20),
                  const SizedBox(width: 4),
                  Text(vendor.rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 18),
            const SizedBox(width: 8),
            const Text('Chennai, India', style: TextStyle(fontSize: 14)),
            const Spacer(),
            Text(
              '₹${vendor.price}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About Vendor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'One of the most reputed vendors in the region, providing top-notch services for all kinds of events. We specialize in high-end luxury events and have over 10 years of experience.',
            style: TextStyle(fontSize: 14, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildServices(BuildContext context) {
    final services = ['Premium Setup', 'On-site Support', 'Custom Packages', 'Equipment Rental'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Services Offered', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: services.map((s) => _buildServiceChip(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceChip(String label) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: BorderRadius.circular(12),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildActions(BuildContext context, String? eventId) {
    final vendorProvider = context.read<VendorProvider>();
    final budgetProvider = context.read<BudgetProvider>();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedPressable(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => OrganizerChatScreen(name: vendor.name, phone: '+91 98765 43210')));
                },
                child: GlassCard(
                  opacity: 1.0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedPressable(
                onTap: () => _handleCall(context, vendor.name, '+91 98765 43210'),
                child: GlassCard(
                  opacity: 0.8,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Call', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedPressable(
          onTap: () => vendorProvider.toggleShortlist(vendor.id),
          child: GlassCard(
            opacity: vendor.isShortlisted ? 0.1 : 0.05,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  vendor.isShortlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  vendor.isShortlisted ? 'Shortlisted' : 'Add to Shortlist',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 32),
        AnimatedPressable(
          onTap: eventId == null || vendor.isBooked
              ? null
              : () {
                  vendorProvider.bookVendor(vendor.id);
                  budgetProvider.addExpense(eventId, 'Booking: ${vendor.name}', vendor.price, vendor.category.name);
                },
          child: GlassCard(
            opacity: 1.0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                vendor.isBooked ? 'Already Booked' : 'Request Booking',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleCall(BuildContext context, String name, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vendor: $name', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Phone: $phone'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phone));
              Navigator.pop(context);
            },
            child: const Text('Copy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final Uri launchUri = Uri(scheme: 'tel', path: phone);
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              }
              Navigator.pop(context);
            },
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }
}
