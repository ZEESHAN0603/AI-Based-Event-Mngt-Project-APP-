import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/shortlist_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/design_system.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final events = context.watch<EventProvider>().events;
    final shortlisted = context.watch<ShortlistProvider>().shortlistedItems;
    final name = user.userName;
    final email = user.userEmail;
    final role = user.selectedRole;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient Header ─────────────────────────────────────────
            _buildHeader(context, name, email, role),
            // ── Stats ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  _statCard(context, '${events.length}', 'Events', Icons.event_rounded),
                  const SizedBox(width: 12),
                  _statCard(context, '${shortlisted.length}', 'Shortlisted', Icons.favorite_rounded),
                  const SizedBox(width: 12),
                  _statCard(context, '0', 'Bookings', Icons.book_online_rounded),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── Account Info ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _listTile(
                          icon: Icons.person_rounded,
                          iconColor: AppColors.primary,
                          title: 'Name',
                          subtitle: name.isEmpty ? 'Not set' : name,
                        ),
                        _divider(isDark),
                        _listTile(
                          icon: Icons.email_rounded,
                          iconColor: AppColors.secondary,
                          title: 'Email',
                          subtitle: email.isEmpty ? 'Not set' : email,
                        ),
                        _divider(isDark),
                        _listTile(
                          icon: Icons.badge_rounded,
                          iconColor: AppColors.warning,
                          title: 'Role',
                          subtitle: _roleLabel(role),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── Settings ──────────────────────────────────────────
                  const Text('Settings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _listTile(
                          icon: Icons.notifications_rounded,
                          iconColor: AppColors.success,
                          title: 'Notifications',
                          subtitle: 'Manage alerts and reminders',
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                        _divider(isDark),
                        _listTile(
                          icon: Icons.security_rounded,
                          iconColor: AppColors.error,
                          title: 'Privacy & Security',
                          subtitle: 'Manage your data',
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                        _divider(isDark),
                        _listTile(
                          icon: Icons.help_outline_rounded,
                          iconColor: Colors.grey,
                          title: 'Help & Support',
                          subtitle: 'FAQs and contact',
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // ── Logout ────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<UserProvider>().logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/role-selection', (r) => false);
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // ── App version ───────────────────────────────────────
                  Center(
                    child: Text(
                      'EventLink v1.0.0 • Made with ❤️',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String name, String email, UserRole? role) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name.isEmpty ? 'User' : name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _roleLabel(role),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _listTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      trailing: trailing,
    );
  }

  Widget _divider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 16),
      child: Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFE2E8F0),
      ),
    );
  }

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.organizer: return '🎉 Event Organizer';
      case UserRole.vendor: return '🏪 Vendor';
      case UserRole.admin: return '🛡️ Administrator';
      default: return 'User';
    }
  }
}
