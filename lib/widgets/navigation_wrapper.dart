import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../screens/organizer/organizer_dashboard.dart';
import '../screens/vendor/vendor_dashboard.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_vendors.dart';
import '../screens/admin/admin_bookings.dart';
import '../screens/admin/admin_users.dart';
import '../screens/admin/admin_content.dart';
import '../screens/organizer/budget_overview.dart';
import '../screens/organizer/vendor_categories.dart';
import '../screens/organizer/ideas_blogs.dart';
import '../screens/organizer/profile_screen.dart';
import '../screens/organizer/ai_chatbot.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;
  bool _navigationPending = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final UserRole? role = userProvider.selectedRole;
    final bool isAuthenticated = userProvider.isAuthenticated;

    // Guard against setState-during-build by deferring navigation
    if (role == null || !isAuthenticated) {
      if (!_navigationPending) {
        _navigationPending = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/role-selection', (r) => false);
          }
        });
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (role == UserRole.vendor) return const VendorDashboard();

    final selectedEvent = context.watch<EventProvider>().selectedEvent;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        final shouldExit = await _showExitDialog(context);
        if (shouldExit && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        body: _getScreens(role, selectedEvent)[_currentIndex],
        bottomNavigationBar: _buildNavBar(role),
        floatingActionButton: role == UserRole.organizer
            ? _buildAiFab(context)
            : null,
      ),
    );
  }

  Widget _buildNavBar(UserRole role) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (i) => setState(() => _currentIndex = i),
      destinations: _getDestinations(role),
    );
  }

  Widget _buildAiFab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AIChatbotScreen()),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        label: const Text(
          'Nanban AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  List<Widget> _getScreens(UserRole role, Event? selectedEvent) {
    switch (role) {
      case UserRole.organizer:
        return [
          const OrganizerDashboard(),
          selectedEvent != null
              ? VendorCategoriesScreen(event: selectedEvent)
              : const _NoEventPlaceholder(),
          const BudgetOverviewScreen(),
          const IdeasBlogsScreen(),
          const ProfileScreen(),
        ];
      case UserRole.vendor:
        return [const VendorDashboard()];
      case UserRole.admin:
        return [
          const AdminDashboard(),
          const AdminVendorsScreen(),
          const AdminBookingsScreen(),
          const AdminUsersScreen(),
          const AdminContentScreen(),
        ];
    }
  }

  List<NavigationDestination> _getDestinations(UserRole role) {
    switch (role) {
      case UserRole.organizer:
        return const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Vendors',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article_rounded),
            label: 'Ideas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ];
      case UserRole.vendor:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
        ];
      case UserRole.admin:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business_rounded),
            label: 'Vendors',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article_rounded),
            label: 'Content',
          ),
        ];
    }
  }
}

class _NoEventPlaceholder extends StatelessWidget {
  const _NoEventPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                child: const Icon(Icons.event_note_rounded,
                    size: 36, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Event Selected',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select an event from the Home tab to browse vendors.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
