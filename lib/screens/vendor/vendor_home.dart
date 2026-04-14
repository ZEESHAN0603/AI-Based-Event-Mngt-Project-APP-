import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';
import 'vendor_reviews.dart';

class VendorHomeScreen extends StatelessWidget {
  final Function(int)? onTabChange;
  const VendorHomeScreen({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Welcome Back!',
            subtitle: 'Manage your events and bookings',
          ),
          Expanded(
            child: AnimationLimiter(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    _buildAlertsSection(context),
                    const SizedBox(height: 24),
                    _buildStatsRow(context),
                    const SizedBox(height: 32),
                    _buildTodaySchedule(context),
                    const SizedBox(height: 32),
                    _buildRecentReviews(context),
                    const SizedBox(height: 32),
                    _buildQuickActions(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context) {
    return AnimatedPressable(
      onTap: () => onTabChange?.call(2),
      child: GlassCard(
        opacity: 0.1,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.notifications_active_outlined, size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Booking Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Rahul S. for Dec 22nd', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statCard(context, 'Total Bookings', '24', Icons.book_online_outlined, Colors.indigo)),
        const SizedBox(width: 16),
        Expanded(child: _statCard(context, 'Earnings', '₹4.85L', Icons.payments_outlined, Colors.teal)),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today\'s Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _scheduleItem(context, 'Morning Prep', '09:00 AM', 'Elite Banquet Hall'),
        const SizedBox(height: 12),
        _scheduleItem(context, 'Mehendi Ceremony', '11:00 AM', 'Greenwood Resort'),
      ],
    );
  }

  Widget _scheduleItem(BuildContext context, String title, String time, String location) {
    return GlassCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.access_time_rounded, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text('${time} • ${location}', style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.more_vert, size: 18),
      ),
    );
  }

  Widget _buildRecentReviews(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorReviewsScreen()));
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _reviewMiniCard('Amit P.', 'The food was absolutely delicious! Highly recommended.', 5),
      ],
    );
  }

  Widget _reviewMiniCard(String name, String comment, int stars) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              ...List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < stars ? Colors.amber : Colors.grey[300])),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: TextStyle(fontSize: 13, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionItem(context, Icons.calendar_month_outlined, 'Availability', () => onTabChange?.call(3)),
            _actionItem(context, Icons.star_outline_rounded, 'Ratings', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorReviewsScreen()));
            }),
            _actionItem(context, Icons.photo_library_outlined, 'Portfolio', () => onTabChange?.call(4)),
          ],
        ),
      ],
    );
  }

  Widget _actionItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return AnimatedPressable(
      onTap: onTap,
      child: Column(
        children: [
          GlassCard(
            blur: 10,
            opacity: 0.1,
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
