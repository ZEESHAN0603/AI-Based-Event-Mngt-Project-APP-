import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../providers/user_provider.dart';
import 'package:evora/widgets/glass_container.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  Timer? _longPressTimer;

  void _startLongPressTimer() {
    _longPressTimer = Timer(const Duration(seconds: 5), () {
      HapticFeedback.mediumImpact();
      _launchAdminDashboard();
    });
  }

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  Future<void> _launchAdminDashboard() async {
    final adminUrl = Uri.parse('https://admin-hazel-gamma-33.vercel.app/');
    final mode = kIsWeb
        ? LaunchMode.platformDefault
        : LaunchMode.externalApplication;

    try {
      if (await canLaunchUrl(adminUrl)) {
        await launchUrl(adminUrl, mode: mode);
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Admin Dashboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTapDown: (_) => _startLongPressTimer(),
                  onTapUp: (_) => _cancelLongPressTimer(),
                  onTapCancel: () => _cancelLongPressTimer(),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_note,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to EventLink',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI-Based Event Vendor Management',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'Choose your role',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildRoleCard(
                  context,
                  'Event Organizer',
                  'Plan and manage your events',
                  Icons.event,
                  UserRole.organizer,
                ),
                const SizedBox(height: 16),
                _buildRoleCard(
                  context,
                  'Vendor',
                  'Offer services and manage bookings',
                  Icons.store,
                  UserRole.vendor,
                ),
                const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    UserRole role, {
    bool isWebRedirect = false,
  }) {
    final color = isWebRedirect
        ? Colors.purple
        : Theme.of(context).primaryColor;

    return GlassContainer(
      child: InkWell(
        onTap: () {
          if (isWebRedirect) {
            _launchAdminDashboard();
          } else {
            context.read<UserProvider>().setRole(role);
            Navigator.pushNamed(context, '/login');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isWebRedirect) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color:
                                      Colors.purple.withValues(alpha: 0.4)),
                            ),
                            child: const Text(
                              'WEB',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isWebRedirect ? Colors.purple : null,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isWebRedirect ? Icons.open_in_browser : Icons.arrow_forward_ios,
                size: isWebRedirect ? 20 : 16,
                color: isWebRedirect ? Colors.purple : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
