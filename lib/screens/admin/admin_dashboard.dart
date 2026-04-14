import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/vendor.dart';
import 'admin_vendor_detail.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final vendorProvider = context.watch<VendorProvider>();

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Admin Console',
            subtitle: 'Platform analytics and management',
          ),
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 800)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildOverviewSkeleton(context),
                      const SizedBox(height: 32),
                      const SkeletonLoader(width: 150, height: 24),
                      const SizedBox(height: 16),
                      const SkeletonLoader(width: double.infinity, height: 150, borderRadius: 24),
                    ],
                  );
                }

                return AnimationLimiter(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        _buildOverviewCards(context, adminProvider, vendorProvider),
                        const SizedBox(height: 32),
                        _buildAnalyticsSection(context),
                        const SizedBox(height: 32),
                        _buildVendorApprovalList(context, vendorProvider),
                        const SizedBox(height: 32),
                        _buildActivityLog(context, adminProvider),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSkeleton(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: SkeletonLoader(width: double.infinity, height: MediaQuery.of(context).size.height * 0.15, borderRadius: 24)),
            const SizedBox(width: 16),
            Expanded(child: SkeletonLoader(width: double.infinity, height: MediaQuery.of(context).size.height * 0.15, borderRadius: 24)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: SkeletonLoader(width: double.infinity, height: MediaQuery.of(context).size.height * 0.15, borderRadius: 24)),
            const SizedBox(width: 16),
            Expanded(child: SkeletonLoader(width: double.infinity, height: MediaQuery.of(context).size.height * 0.15, borderRadius: 24)),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCards(BuildContext context, AdminProvider admin, VendorProvider vendor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _adminStatCard(context, 'Total Organizers', '${admin.users.length}', Icons.groups_rounded, Colors.indigo)),
            const SizedBox(width: 16),
            Expanded(child: _adminStatCard(context, 'Total Vendors', '${vendor.vendors.length}', Icons.business_rounded, Colors.purple)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _adminStatCard(context, 'Total Bookings', '${admin.bookings.length}', Icons.event_available_rounded, Colors.teal)),
            const SizedBox(width: 16),
            Expanded(child: _adminStatCard(context, 'Total Revenue', '₹ 4.5L', Icons.account_balance_wallet_rounded, Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _adminStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Platform Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _analyticRow('Most Booked Category', 'Catering (45%)', Colors.indigo),
              const Divider(height: 24),
              _analyticRow('App Popularity', '+12% this week', Colors.teal),
              const Divider(height: 24),
              _analyticRow('Active Events', '128 Ongoing', Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _analyticRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildVendorApprovalList(BuildContext context, VendorProvider provider) {
    final pending = provider.pendingVendors;
    if (pending.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pending Approvals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 8),
        ...pending.take(3).map((v) => _approvalItem(context, v, provider)).toList(),
      ],
    );
  }

  Widget _approvalItem(BuildContext context, Vendor v, VendorProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(v.category.name.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => provider.updateVendorStatus(v.id, VendorStatus.approved),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminVendorDetailScreen(vendor: v)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityLog(BuildContext context, AdminProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: provider.activityLog.map((log) => _logItem(log)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _logItem(String log) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        child: const Icon(Icons.history_rounded, size: 16),
      ),
      title: Text(log, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      dense: true,
    );
  }
}
