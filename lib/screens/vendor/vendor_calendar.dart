import 'package:flutter/material.dart';
import '../../widgets/synora_header.dart';
import '../../widgets/design_system.dart';

class VendorCalendarScreen extends StatefulWidget {
  const VendorCalendarScreen({super.key});

  @override
  State<VendorCalendarScreen> createState() => _VendorCalendarScreenState();
}

class _VendorCalendarScreenState extends State<VendorCalendarScreen> {
  // Mock data for availability
  final Map<int, String> _dateStatus = {
    10: 'booked',
    12: 'booked',
    15: 'blocked',
    20: 'booked',
    22: 'booked',
    25: 'blocked',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Event Calendar',
            subtitle: 'Manage your availability',
          ),
          _buildLegend(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: 31,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final status = _dateStatus[day] ?? 'available';
                    Color color;
                    switch (status) {
                      case 'booked': color = Colors.red; break;
                      case 'blocked': color = Colors.grey; break;
                      default: color = Colors.green;
                    }

                    return AnimatedPressable(
                      onTap: () => _showStatusDialog(day),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (status != 'available')
                              Positioned(
                                top: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 3,
                                  backgroundColor: color,
                                ),
                              ),
                          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _legendItem('Available', Colors.green),
          _legendItem('Booked', Colors.red),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            ),
        ),
      ],
    );
  }

  void _showStatusDialog(int day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Day $day Availability', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusChoice(day, 'available', Colors.green, 'Available'),
            _statusChoice(day, 'booked', Colors.red, 'Booked'),
            _statusChoice(day, 'blocked', Colors.grey, 'Blocked/Personal'),
          ],
        ),
      ),
    );
  }

  Widget _statusChoice(int day, String status, Color color, String label) {
    return ListTile(
      onTap: () {
        setState(() => _dateStatus[day] = status);
        Navigator.pop(context);
      },
      leading: CircleAvatar(radius: 8, backgroundColor: color),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
