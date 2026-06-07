import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/availability_provider.dart';
import '../../widgets/synora_header.dart';
import '../../widgets/design_system.dart';

class VendorCalendarScreen extends StatefulWidget {
  const VendorCalendarScreen({super.key});

  @override
  State<VendorCalendarScreen> createState() => _VendorCalendarScreenState();
}

class _VendorCalendarScreenState extends State<VendorCalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvailabilityProvider>().fetchMyAvailability();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _toggleBlockedDate(DateTime date, String? existingId) async {
    final provider = context.read<AvailabilityProvider>();
    bool success;
    if (existingId != null) {
      success = await provider.removeBlockedDate(existingId);
    } else {
      success = await provider.blockDate(_formatDate(date));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Availability updated!' : 'Failed to update availability'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AvailabilityProvider>();
    final blockedDates = provider.blockedDates;
    
    // Simple calendar logic for current month
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Availability',
            subtitle: 'Block dates when you are unavailable',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(monthName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildLegend(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: daysInMonth,
                        itemBuilder: (context, index) {
                          final day = index + 1;
                          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
                          final blockedDateObj = blockedDates.cast<dynamic>().firstWhere(
                                (d) => d.blockedDate.day == day && 
                                       d.blockedDate.month == _currentMonth.month && 
                                       d.blockedDate.year == _currentMonth.year,
                                orElse: () => null,
                              );
                          
                          final isBlocked = blockedDateObj != null;

                          return AnimatedPressable(
                            onTap: () => _toggleBlockedDate(date, blockedDateObj?.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isBlocked ? Colors.grey.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isBlocked ? Colors.grey : Colors.green,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  day.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isBlocked ? Colors.grey : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem('Available', Colors.green),
          const SizedBox(width: 24),
          _legendItem('Blocked', Colors.grey),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
