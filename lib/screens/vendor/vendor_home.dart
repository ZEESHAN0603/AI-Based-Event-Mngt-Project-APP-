import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/vendor_dashboard_provider.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';
import '../../theme/app_theme.dart';
import 'vendor_reviews.dart';

class VendorHomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  const VendorHomeScreen({super.key, this.onTabChange});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorDashboardProvider>().fetchDashboardData();
    });
  }

  Future<void> _refreshData() async {
    await context.read<VendorDashboardProvider>().fetchDashboardData();
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '₹0';
    final double val = double.tryParse(amount.toString()) ?? 0.0;
    if (val >= 100000) {
      return '₹${(val / 100000).toStringAsFixed(1)}L';
    }
    return '₹${val.toStringAsFixed(0)}';
  }

  String _formatMonth(String monthStr) {
    try {
      final parts = monthStr.split('-');
      if (parts.length != 2) return monthStr;
      final year = parts[0].substring(2);
      final monthInt = int.parse(parts[1]);
      final monthName = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][monthInt - 1];
      return '$monthName \'$year';
    } catch (_) {
      return monthStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<VendorDashboardProvider>();
    final isLoading = dashboardProvider.isLoading;
    final error = dashboardProvider.error;
    final data = dashboardProvider.dashboardData;

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: '',
            showBackButton: false,
            useBrandingLayout: true,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: AppColors.primary,
              child: _buildMainContent(isLoading, error, data, dashboardProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    bool isLoading,
    String? error,
    Map<String, dynamic>? data,
    VendorDashboardProvider provider,
  ) {
    if (isLoading && data == null) {
      return _buildSkeletonLoader();
    }

    if (error != null && data == null) {
      return AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Unable to Load Dashboard',
        subtitle: error,
        actionLabel: 'Retry',
        onAction: _refreshData,
      );
    }

    final stats = provider.stats;
    final bookingRequests = provider.bookingRequests;
    final schedule = provider.schedule;
    final reviews = provider.reviews;
    final performance = provider.performance;
    final revenue = provider.revenueAnalytics;
    final availabilityStatus = provider.availabilityStatus;
    final activities = provider.activities;

    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            // Availability widget
            _buildAvailabilityWidget(availabilityStatus),
            const SizedBox(height: 20),

            // Stats row (2x2 grid)
            _buildStatsGrid(stats),
            const SizedBox(height: 20),

            // Performance Analytics
            _buildPerformanceCard(performance),
            const SizedBox(height: 20),

            // Revenue Chart
            _buildRevenueSection(revenue),
            const SizedBox(height: 20),

            // Booking Requests
            _buildBookingRequestsSection(bookingRequests, provider),
            const SizedBox(height: 20),

            // Schedule Section
            _buildScheduleSection(schedule),
            const SizedBox(height: 20),

            // Reviews Section
            _buildReviewsSection(reviews),
            const SizedBox(height: 20),

            // Recent Activity Section
            _buildActivitySection(activities),
            const SizedBox(height: 20),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityWidget(String status) {
    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'available':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'partially booked':
        statusColor = Colors.amber;
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      default:
        statusColor = AppColors.error;
        statusIcon = Icons.block_flipped;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Availability Status',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => widget.onTabChange?.call(3), // Navigate to calendar
            icon: const Icon(Icons.calendar_month_rounded, size: 16),
            label: const Text('Manage'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        _buildStatCard(
          'Total Bookings',
          '${stats['total_bookings'] ?? 0}',
          Icons.book_online_rounded,
          AppColors.primary,
        ),
        _buildStatCard(
          'Pending Requests',
          '${stats['pending_bookings'] ?? 0}',
          Icons.pending_actions_rounded,
          Colors.orange,
        ),
        _buildStatCard(
          'Completed Events',
          '${stats['completed_events'] ?? 0}',
          Icons.check_circle_rounded,
          AppColors.success,
        ),
        _buildStatCard(
          'Monthly Revenue',
          _formatCurrency(stats['monthly_revenue']),
          Icons.currency_rupee_rounded,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
              Icon(icon, size: 18, color: color.withValues(alpha: 0.8)),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(Map<String, dynamic> perf) {
    final double completion = double.tryParse(perf['profile_completion']?.toString() ?? '0') ?? 0.0;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric('Views', '${perf['views'] ?? 0}', Icons.remove_red_eye_outlined),
              _buildMiniMetric('Bookings', '${perf['bookings'] ?? 0}', Icons.calendar_today_rounded),
              _buildMiniMetric('Conv. Rate', '${perf['conversion_rate'] ?? 0}%', Icons.trending_up_rounded),
              _buildMiniMetric('Avg. Rating', '${perf['average_rating'] ?? 0} ⭐', Icons.star_border_rounded),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${completion.toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completion / 100,
              backgroundColor: Colors.grey[200],
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueSection(Map<String, dynamic> revenue) {
    final trendList = revenue['trend'] as List<dynamic>? ?? [];
    double maxAmount = 10000.0;
    for (var t in trendList) {
      final double amt = double.tryParse(t['amount']?.toString() ?? '0') ?? 0.0;
      if (amt > maxAmount) maxAmount = amt;
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Analytics',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trend of the last 6 months',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(revenue['current_month']),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    'This Month',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Custom Bar Chart
          if (trendList.isEmpty)
            Container(
              height: 120,
              child: Center(
                child: Text('No revenue data yet', style: TextStyle(color: Colors.grey[400])),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: trendList.map((t) {
                final double amt = double.tryParse(t['amount']?.toString() ?? '0') ?? 0.0;
                final double heightFactor = (amt / maxAmount).clamp(0.05, 1.0);
                final monthStr = t['month']?.toString() ?? '';

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        _formatCurrency(amt),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: amt > 0 ? Colors.teal : Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 100 * heightFactor,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: amt > 0
                                  ? [Colors.teal.withValues(alpha: 0.5), Colors.teal]
                                  : [Colors.grey[200]!, Colors.grey[300]!],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatMonth(monthStr),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingRequestsSection(List<dynamic> requests, VendorDashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Requests',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (requests.isEmpty)
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded, color: Colors.grey[300], size: 36),
                  const SizedBox(height: 10),
                  Text(
                    'No pending requests',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final req = requests[idx];
              if (req is! Map) return const SizedBox.shrink();
              final String bookingId = req['id'] ?? '';
              final String name = req['organizer_name'] ?? 'Unknown Organizer';
              final String event = req['event_name'] ?? 'Unknown Event';
              final String date = req['event_date'] ?? '';
              final double amt = double.tryParse(req['amount']?.toString() ?? '0') ?? 0.0;

              return AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                event,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(amt),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          date.isNotEmpty ? date : 'No Date Provided',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isActionLoading
                                ? null
                                : () async {
                                    setState(() => _isActionLoading = true);
                                    final success = await provider.updateRequestStatus(bookingId, 'rejected');
                                    setState(() => _isActionLoading = false);
                                    if (mounted && success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Booking request rejected')),
                                      );
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isActionLoading
                                ? null
                                : () async {
                                    setState(() => _isActionLoading = true);
                                    final success = await provider.updateRequestStatus(bookingId, 'accepted');
                                    setState(() => _isActionLoading = false);
                                    if (mounted && success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Booking request accepted!')),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildScheduleSection(List<dynamic> schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Schedule',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (schedule.isEmpty)
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Center(
              child: Text(
                'No upcoming events scheduled',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedule.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final item = schedule[idx];
              if (item is! Map) return const SizedBox.shrink();
              return AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.event_note_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['event_name'] ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Organizer: ${item['organizer_name']}',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 13, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item['venue'] ?? '',
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['event_date'] ?? '',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          item['time'] ?? '09:00 AM',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildReviewsSection(List<dynamic> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer Reviews',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VendorReviewsScreen()),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (reviews.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: Text('No reviews yet', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final rev = reviews[idx];
              if (rev is! Map) return const SizedBox.shrink();
              final stars = int.tryParse(rev['rating']?.toString() ?? '5') ?? 5;
              final comment = rev['comment'] ?? 'No comment provided';
              final name = rev['reviewer_name'] ?? 'Anonymous';

              return AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: i < stars ? Colors.amber : Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      comment,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildActivitySection(List<dynamic> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (activities.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: Text('No activities recorded', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, idx) {
              final act = activities[idx];
              if (act is! Map) return const SizedBox.shrink();
              final title = act['title'] ?? '';
              final desc = act['description'] ?? '';
              final dateStr = act['created_at'] ?? '';
              final type = act['type'] ?? '';

              IconData iconData;
              Color iconColor;
              switch (type) {
                case 'booking_received':
                  iconData = Icons.receipt_long_rounded;
                  iconColor = Colors.orange;
                  break;
                case 'booking_approved':
                  iconData = Icons.check_circle_rounded;
                  iconColor = AppColors.success;
                  break;
                case 'review_received':
                  iconData = Icons.star_rate_rounded;
                  iconColor = Colors.amber;
                  break;
                case 'availability_updated':
                  iconData = Icons.calendar_month_rounded;
                  iconColor = AppColors.primary;
                  break;
                default:
                  iconData = Icons.info_outline_rounded;
                  iconColor = Colors.grey;
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline dots & line
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, size: 14, color: iconColor),
                        ),
                        if (idx < activities.length - 1)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              color: Colors.grey[200],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Activity details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  dateStr.isNotEmpty
                                      ? dateStr.substring(11, 16) // e.g. "14:30"
                                      : '',
                                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.95,
          children: [
            _buildActionItem(
              Icons.calendar_month_outlined,
              'Calendar',
              () => widget.onTabChange?.call(3),
            ),
            _buildActionItem(
              Icons.star_outline_rounded,
              'Ratings',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VendorReviewsScreen()),
              ),
            ),
            _buildActionItem(
              Icons.photo_library_outlined,
              'Portfolio',
              () => widget.onTabChange?.call(4),
            ),
            _buildActionItem(
              Icons.event_note_rounded,
              'Bookings',
              () => widget.onTabChange?.call(2),
            ),
            _buildActionItem(
              Icons.message_outlined,
              'Messages',
              () => widget.onTabChange?.call(1),
            ),
            _buildActionItem(
              Icons.analytics_outlined,
              'Analytics',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics section refreshed!')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return AnimatedPressable(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppCard(
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(16),
            child: Icon(icon, size: 26, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        const SkeletonLoader(width: double.infinity, height: 70),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.35,
          children: List.generate(4, (_) => const SkeletonLoader(width: 100, height: 100)),
        ),
        const SizedBox(height: 20),
        const SkeletonLoader(width: double.infinity, height: 160),
        const SizedBox(height: 20),
        const SkeletonLoader(width: double.infinity, height: 200),
      ],
    );
  }
}
