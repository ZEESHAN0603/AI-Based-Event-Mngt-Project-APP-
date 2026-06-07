import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/event.dart';
import '../../theme/app_theme.dart';
import '../../widgets/design_system.dart';
import 'vendor_categories.dart';
import 'ai_chatbot.dart';
import 'all_events.dart';
import 'event_details.dart';
import 'edit_event.dart';
import 'manage_vendors.dart';
import 'create_event.dart';
import 'event_checklist.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final eventProvider = context.read<EventProvider>();
    await eventProvider.fetchEvents();
    if (mounted && eventProvider.selectedEventId != null) {
      setState(() {
        _selectedEventIndex = eventProvider.events
            .indexWhere((e) => e.id == eventProvider.selectedEventId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final user = context.watch<UserProvider>();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── Gradient Header ─────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context, user, eventProvider)),
            // ── Content ─────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              sliver: eventProvider.isLoading
                  ? SliverToBoxAdapter(child: _buildSkeleton(context))
                  : eventProvider.events.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmpty(context))
                      : SliverList(
                          delegate: SliverChildListDelegate([
                            _buildQuickActions(context, eventProvider),
                            const SizedBox(height: 28),
                            _buildEventsHeader(context, eventProvider),
                            const SizedBox(height: 16),
                            ..._buildEventCards(context, eventProvider),
                          ]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, UserProvider user, EventProvider ep) {
    return Container(
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SynoraLogo(size: 30, light: true),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white70, size: 22),
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text('No new notifications'))),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Hello, ${user.userName.split(' ').first} 👋',
                style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Plan your next event with EventLink',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 20),
              // Stats row
              Row(
                children: [
                  _statPill(Icons.event_rounded, '${ep.events.length}', 'Events'),
                  const SizedBox(width: 12),
                  _statPill(Icons.people_rounded, '0', 'Vendors'),
                  const SizedBox(width: 12),
                  _statPill(Icons.task_alt_rounded, '0', 'Tasks'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statPill(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ───────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, EventProvider ep) {
    final actions = [
      _ActionData(
        icon: Icons.storefront_rounded,
        label: 'Find\nVendors',
        colors: [const Color(0xFF6366F1), const Color(0xFF818CF8)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => VendorCategoriesScreen(event: ep.selectedEvent)),
        ),
      ),
      _ActionData(
        icon: Icons.add_circle_rounded,
        label: 'Create\nEvent',
        colors: [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
        onTap: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CreateEventScreen()));
          _loadData();
        },
      ),
      _ActionData(
        icon: Icons.checklist_rounded,
        label: 'Checklist',
        colors: [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EventChecklistScreen())),
      ),
      _ActionData(
        icon: Icons.smart_toy_rounded,
        label: 'AI\nAssistant',
        colors: [const Color(0xFF10B981), const Color(0xFF34D399)],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AIChatbotScreen())),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          Icon(Icons.bolt_rounded, color: AppColors.warning, size: 20),
        ]),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: actions.map((a) => _actionCard(a)).toList(),
        ),
      ],
    );
  }

  Widget _actionCard(_ActionData a) {
    return AnimatedPressable(
      onTap: a.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: a.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: a.colors.first.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(a.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                a.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Events Section ──────────────────────────────────────────────────────────

  Widget _buildEventsHeader(BuildContext context, EventProvider ep) {
    return Row(children: [
      const Text('Your Events',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Spacer(),
      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AllEventsScreen()),
        ),
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        child: const Text('See All'),
      ),
    ]);
  }

  List<Widget> _buildEventCards(BuildContext context, EventProvider ep) {
    return ep.events.asMap().entries.map((entry) {
      final index = entry.key;
      final event = entry.value;
      final isSelected = _selectedEventIndex == index;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _EventCard(
          event: event,
          isSelected: isSelected,
          onSelect: () {
            setState(() {
              _selectedEventIndex = isSelected ? -1 : index;
            });
            final id = _selectedEventIndex != -1
                ? ep.events[_selectedEventIndex].id
                : null;
            ep.selectEvent(id ?? '');
          },
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditEventScreen(event: event)),
          ),
          onVendors: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ManageVendorsScreen(event: event)),
          ),
          onView: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EventDetailsScreen(event: event)),
          ),
        ),
      );
    }).toList();
  }

  // ── Loading / Empty ─────────────────────────────────────────────────────────

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      children: [
        const SkeletonLoader(width: double.infinity, height: 56, borderRadius: 14),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: List.generate(
              4,
              (_) => const SkeletonLoader(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 20)),
        ),
        const SizedBox(height: 20),
        ...List.generate(
          2,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SkeletonLoader(
              width: double.infinity,
              height: 130,
              borderRadius: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return AppEmptyState(
      icon: Icons.event_note_rounded,
      title: 'No Events Yet',
      subtitle: 'Create your first event and start planning!',
      actionLabel: 'Create Event',
      onAction: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateEventScreen()),
        );
        _loadData();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Event Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final Event event;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onVendors;
  final VoidCallback onView;

  const _EventCard({
    required this.event,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onVendors,
    required this.onView,
  });

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'wedding': return const Color(0xFFEC4899);
      case 'birthday': return const Color(0xFFF59E0B);
      case 'corporate': return const Color(0xFF0EA5E9);
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _typeColor(event.type);

    return AnimatedPressable(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.6)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            else if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          children: [
            // Top section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_typeIcon(event.type), color: typeColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            AppBadge(
                              label: event.type,
                              backgroundColor: typeColor.withValues(alpha: 0.12),
                              textColor: typeColor,
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6),
                              const AppBadge(
                                label: '✓ Selected',
                                backgroundColor: Color(0xFF22C55E),
                                textColor: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Info chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _infoChip(Icons.calendar_today_rounded,
                      DateFormat('dd MMM yyyy').format(event.date)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _infoChip(
                        Icons.location_on_rounded, event.location),
                  ),
                ],
              ),
            ),
            // Budget
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _infoChip(Icons.account_balance_wallet_rounded,
                      '₹${NumberFormat('#,##,###').format(event.totalBudget.toInt())}'),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE2E8F0)),
            // Actions — use Wrap to prevent overflow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                children: [
                  TextButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_rounded, size: 14),
                    label: const Text('View', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 10)),
                  ),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 14),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10)),
                  ),
                  TextButton.icon(
                    onPressed: onVendors,
                    icon: const Icon(Icons.people_rounded, size: 14),
                    label: const Text('Vendors', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'wedding': return Icons.favorite_rounded;
      case 'birthday': return Icons.cake_rounded;
      case 'corporate': return Icons.business_center_rounded;
      default: return Icons.celebration_rounded;
    }
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });
}
