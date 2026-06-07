import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_client.dart';
import 'theme/app_theme.dart';
import 'providers/user_provider.dart';
import 'providers/event_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/task_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/availability_provider.dart';
import 'theme/theme_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/shortlist_provider.dart';
import 'providers/vendor_dashboard_provider.dart';
import 'screens/role_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'widgets/navigation_wrapper.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => AvailabilityProvider()),
        ChangeNotifierProvider(create: (_) => ShortlistProvider()),
        ChangeNotifierProvider(create: (_) => VendorDashboardProvider()),
      ],
      child: const EventLinkApp(),
    ),
  );
}

class EventLinkApp extends StatefulWidget {
  const EventLinkApp({super.key});

  @override
  State<EventLinkApp> createState() => _EventLinkAppState();
}

class _EventLinkAppState extends State<EventLinkApp> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final userProvider = context.read<UserProvider>();
    // Global unauthorized handler
    ApiClient.onUnauthorized = () {
      userProvider.logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/role-selection', (route) => false);
    };
    await userProvider.tryAutoLogin();
    setState(() {
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Consumer2<ThemeProvider, UserProvider>(
      builder: (context, themeProvider, userProvider, child) {
        return MaterialApp(
          title: 'EventLink',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: userProvider.isAuthenticated ? '/home' : '/role-selection',
          routes: {
            '/role-selection': (context) => const RoleSelectionScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => const NavigationWrapper(),
          },
        );
      },
    );
  }
}
