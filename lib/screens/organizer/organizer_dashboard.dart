import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../models/event.dart';
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
import '../../widgets/synora_header.dart';
import 'vendor_details.dart';
import 'edit_event.dart';
import 'manage_vendors.dart';
import 'create_event.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  int _selectedEventIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final eventProvider = context.read<EventProvider>();
    await eventProvider.fetchEvents();
    if (mounted) {
      if (eventProvider.selectedEventId != null) {
        setState(() {
          _selectedEventIndex = eventProvider.events.indexWhere((e) => e.id == eventProvider.selectedEventId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    
    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Hello, Organizer!',
            subtitle: 'Plan your next event with Synora',
          ),
          Expanded(
            child: eventProvider.isLoading
                ? _buildLoadingSkeleton()
                : eventProvider.events.isEmpty
                    ? _buildEmptyState()
                    : AnimationLimiter(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(child: widget),
                            ),
                            children: [
                              _buildStatsBar(context, eventProvider),
                              const SizedBox(height: 16),
                              _buildQuickActions(context, eventProvider),
                              const SizedBox(height: 16),
                              _buildUpcomingEvents(context, eventProvider),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_note, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No events found. Create your first event!',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEventScreen())),
            child: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        SkeletonLoader(width: double.infinity, height: MediaQuery.of(context).size.height * 0.15, borderRadius: 24),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: List.generate(4, (i) => Column(
            children: [
              const SkeletonLoader(width: 50, height: 50, borderRadius: 16),
              const SizedBox(height: 8),
              const SkeletonLoader(width: 40, height: 12),
            ])),
        ),
        const SizedBox(height: 16),
        const SkeletonLoader(width: 150, height: 24),
        const SizedBox(height: 16),
        ...List.generate(2, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonLoader(width: double.infinity, height: MediaQuery.of(context).size.height * 0.1, borderRadius: 24))),
      ],
    );
  }

  Widget _buildStatsBar(BuildContext context, EventProvider provider) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      blur: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, provider.events.length.toString(), 'Events', Icons.event_available, Colors.blue),
          _buildStatVerticalDivider(context),
          _buildStatItem(context, '0', 'Budget', Icons.account_balance_wallet, Colors.orange),
          _buildStatVerticalDivider(context),
          _buildStatItem(context, '0', 'Tasks', Icons.checklist, Colors.purple),
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

  Widget _buildQuickActions(BuildContext context, EventProvider eventProvider) {
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
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _actionItem(context, Icons.person_search, 'Find Vendors', () {
              final selectedEvent = eventProvider.selectedEvent;
              Navigator.push(context, MaterialPageRoute(builder: (context) => VendorCategoriesScreen(event: selectedEvent)));
            }),
            _actionItem(context, Icons.add_circle_outline, 'Create Event', () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEventScreen()));
            }),
            _actionItem(context, Icons.checklist, 'Checklist', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EventChecklistScreen()));
            }),
            _actionItem(context, Icons.chat_bubble_outline, 'AI Assistant', () {
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
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              label, 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.events.length,
          itemBuilder: (context, index) {
            final event = provider.events[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: AnimatedPressable(
                onTap: () {
                  setState(() {
                    _selectedEventIndex = (_selectedEventIndex == index) ? -1 : index;
                  });
                  final eventId = _selectedEventIndex != -1 ? provider.events[_selectedEventIndex].id : null;
                  provider.selectEvent(eventId ?? ''); 
                },
                child: GlassCard(
                  color: _selectedEventIndex == index ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : null,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        leading: Checkbox(
                          value: _selectedEventIndex == index,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (_) {
                            setState(() {
                              _selectedEventIndex = (_selectedEventIndex == index) ? -1 : index;
                            });
                            final eventId = _selectedEventIndex != -1 ? provider.events[_selectedEventIndex].id : null;
                            provider.selectEvent(eventId ?? '');
                          },
                        ),
                        title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                          '${event.date.day}/${event.date.month} • Total: ₹${event.totalBudget}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                      const Divider(height: 24, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 4,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditEventScreen(event: event)));
                                  },
                                  icon: const Icon(Icons.edit, size: 14),
                                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ManageVendorsScreen(event: event)));
                                  },
                                  icon: const Icon(Icons.people, size: 14),
                                  label: const Text('Vendors', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailsScreen(event: event)));
                                  },
                                  icon: const Icon(Icons.visibility_outlined, size: 14),
                                  label: const Text('View', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
