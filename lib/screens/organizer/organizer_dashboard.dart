import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../theme/theme_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/task_provider.dart';
import 'vendor_categories.dart';
import 'organizer_messages.dart';
import 'event_checklist.dart';
import 'ai_chatbot.dart';
import 'all_events.dart';
import 'event_details.dart';
import '../../widgets/design_system.dart';
import '../../widgets/dashboard_header.dart';
import 'vendor_details.dart';

class OrganizerDashboard extends StatelessWidget {
  const OrganizerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: DashboardHeader(
                  title: 'Hello, Organizer!',
                  subtitle: 'Plan your next event with Synora',
                ),
              ),
              Positioned(
                top: 40,
                right: 24,
                child: IconButton(
                  icon: const Icon(Icons.dark_mode),
                  onPressed: () {
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 800)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: [
                      SkeletonLoader(width: double.infinity, height: MediaQuery.of(context).size.height * 0.15, borderRadius: 24),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (i) => Column(
                          children: [
                            const SkeletonLoader(width: 50, height: 50, borderRadius: 16),
                            const SizedBox(height: 8),
                            const SkeletonLoader(width: 40, height: 12),
                          ])),
                      ),
                      const SizedBox(height: 32),
                      const SkeletonLoader(width: 150, height: 24),
                      const SizedBox(height: 16),
                      ...List.generate(2, (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SkeletonLoader(width: double.infinity, height: MediaQuery.of(context).size.height * 0.1, borderRadius: 24))),
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
                        _buildStatsBar(context),
                        const SizedBox(height: 32),
                        _buildQuickActions(context),
                        const SizedBox(height: 32),
                        _buildUpcomingEvents(context, eventProvider),
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

  Widget _buildStatsBar(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      blur: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, '3', 'Active', Icons.event_available, Colors.blue),
          _buildStatVerticalDivider(context),
          _buildStatItem(context, '72%', 'Budget', Icons.account_balance_wallet, Colors.orange),
          _buildStatVerticalDivider(context),
          _buildStatItem(context, '15', 'Tasks', Icons.checklist, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatVerticalDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12,
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Icon(Icons.bolt),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionItem(context, Icons.person_search, 'Vendors', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorCategoriesScreen()));
            }),
            _actionItem(context, Icons.message_outlined, 'Messages', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrganizerMessagesScreen()));
            }),
            _actionItem(context, Icons.checklist, 'Checklist', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EventChecklistScreen()));
            }),
            _actionItem(context, Icons.chat_bubble_outline, 'AI Chat', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AIChatbotScreen()));
            }),
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
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(20),
            child: Icon(icon, size: 24),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context, EventProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllEventsScreen())),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...provider.events.map((event) {
          final isSelected = provider.selectedEventId == event.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: AnimatedPressable(
              onTap: () => provider.selectEvent(event.id),
              child: GlassCard(
                color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : null,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      leading: Checkbox(
                        value: isSelected,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (_) => provider.selectEvent(event.id),
                      ),
                      title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(
                        '${event.date.day}/${event.date.month} • Total: ₹${event.totalBudget}',
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(Icons.calendar_today_outlined, size: 18, ),
                    ),
                    _buildShortlistPreview(context, event.id),
                    const Divider(height: 24, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isSelected ? 'Selected' : 'Click to select',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailsScreen(event: event)));
                            },
                            icon: const Icon(Icons.visibility_outlined, size: 16),
                            label: const Text('View Detail', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildShortlistPreview(BuildContext context, String eventId) {
    final taskProvider = context.watch<TaskProvider>();
    final vendorProvider = context.watch<VendorProvider>();
    
    final vendorTasks = taskProvider.getTasksForEvent(eventId)
        .where((t) => t.vendorId != null)
        .take(3)
        .toList();
        
    if (vendorTasks.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text('Shortlisted Vendors:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: vendorTasks.map((task) {
              final vendor = vendorProvider.vendors.firstWhere((v) => v.id == task.vendorId);
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: ActionChip(
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelStyle: const TextStyle(fontSize: 9),
                  label: Text(vendor.name),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorDetailScreen(vendor: vendor),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
