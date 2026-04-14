import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
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

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = context.watch<UserProvider>();
    final UserRole? role = userProvider.selectedRole;

    if (role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (role == UserRole.vendor) {
      return const VendorDashboard();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        final shouldExit = await _showExitDialog(context);
        if (shouldExit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
          body: _getScreens(role)[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            items: _getNavItems(role),
          ),
          floatingActionButton: role == UserRole.organizer ? FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIChatbotScreen()),
              );
            },
            tooltip: 'AI Assistant',
            child: const Icon(Icons.chat),
          ) : null,
        ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes', style: TextStyle()),
          ),
        ],
      ),
    ) ?? false;
  }

  List<Widget> _getScreens(UserRole role) {
    switch (role) {
      case UserRole.organizer:
        return [
          const OrganizerDashboard(),
          const VendorCategoriesScreen(),
          const BudgetOverviewScreen(),
          const IdeasBlogsScreen(),
          const ProfileScreen(),
        ];
      case UserRole.vendor:
        return [
          const VendorDashboard(),
          const Center(child: Text('Schedule')),
          const Center(child: Text('Requests')),
          const Center(child: Text('Messages')),
        ];
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

  List<BottomNavigationBarItem> _getNavItems(UserRole role) {
    switch (role) {
      case UserRole.organizer:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Vendors'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Ideas & Blogs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
      case UserRole.vendor:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        ];
      case UserRole.admin:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.business_outlined), label: 'Vendors'),
          BottomNavigationBarItem(icon: Icon(Icons.event_available_outlined), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Content'),
        ];
    }
  }
}
