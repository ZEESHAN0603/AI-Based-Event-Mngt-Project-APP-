import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/vendor.dart';
import 'organizer_messages.dart';
import '../../widgets/design_system.dart';

class VendorDetailScreen extends StatefulWidget {
  final Vendor vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  bool _isBooking = false;
  bool _isShortlisting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventId = context.read<EventProvider>().selectedEventId;
      if (eventId != null) {
        context.read<ShortlistProvider>().fetchShortlist(eventId);
      }
    });
  }

  Future<void> _toggleShortlist(String? eventId) async {
    if (eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an event first')));
      return;
    }

    setState(() => _isShortlisting = true);
    final shortlistProvider = context.read<ShortlistProvider>();
    final isAlreadyShortlisted = shortlistProvider.isShortlisted(widget.vendor.id);

    bool success;
    if (isAlreadyShortlisted) {
      final shortlistId = shortlistProvider.getShortlistId(widget.vendor.id);
      success = await shortlistProvider.removeFromShortlist(eventId, shortlistId!);
    } else {
      success = await shortlistProvider.addToShortlist(eventId, widget.vendor.id);
    }

    if (mounted) setState(() => _isShortlisting = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAlreadyShortlisted ? 'Removed from shortlist' : 'Added to shortlist')),
      );
    }
  }

  Future<void> _requestBooking(String eventId) async {
    setState(() => _isBooking = true);
    final bookingProvider = context.read<BookingProvider>();
    
    final success = await bookingProvider.createBooking({
      'event_id': eventId,
      'vendor_id': widget.vendor.id,
      'total_amount': widget.vendor.basePriceMin,
      'notes': 'Requested via Synora App',
    });

    if (!mounted) return;
    setState(() => _isBooking = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Booking request sent!' : (bookingProvider.error ?? 'Failed to send request')),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventId = context.watch<EventProvider>().selectedEventId;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                        const SizedBox(height: 24),
                        _buildDescription(context),
                        const SizedBox(height: 24),
                        _buildActions(context, eventId),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
            Image.network(
              widget.vendor.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.business, size: 100, color: Colors.white24),
              ),
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
                    widget.vendor.businessName,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'VENDOR',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
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
                  const Icon(Icons.star_rounded, size: 20, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(widget.vendor.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(widget.vendor.location, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const Spacer(),
            Text(
              '₹${widget.vendor.basePriceMin.toInt()}',
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
          child: Text(
            widget.vendor.description.isNotEmpty 
                ? widget.vendor.description 
                : 'No description provided by the vendor.',
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, String? eventId) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedPressable(
                onTap: () => _toggleShortlist(eventId),
                child: Consumer<ShortlistProvider>(
                  builder: (context, shortlistProvider, child) {
                    final isShortlisted = shortlistProvider.isShortlisted(widget.vendor.id);
                    return GlassCard(
                      color: isShortlisted ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isShortlisted ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isShortlisted ? Theme.of(context).primaryColor : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isShortlisted ? 'Shortlisted' : 'Shortlist',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isShortlisted ? Theme.of(context).primaryColor : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnimatedPressable(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => OrganizerChatScreen(name: widget.vendor.businessName, phone: '+91 98765 43210')));
                },
                child: const GlassCard(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
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
                onTap: () => _handleCall(context, widget.vendor.businessName, '+91 98765 43210'),
                child: const GlassCard(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
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
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        AnimatedPressable(
          onTap: eventId == null || _isBooking
              ? () {
                  if (eventId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an event first')),
                    );
                  }
                }
              : () => _requestBooking(eventId),
          child: GlassCard(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: _isBooking 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Request Booking',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
