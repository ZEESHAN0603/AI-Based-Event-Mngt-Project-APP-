import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import 'event_details.dart';
import '../../widgets/design_system.dart';

class AllEventsScreen extends StatelessWidget {
  const AllEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final events = eventProvider.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      body: events.isEmpty
          ? const Center(child: Text('No events found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final isSelected = eventProvider.selectedEventId == event.id;
                return GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (_) => eventProvider.selectEvent(event.id),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${event.date.day}/${event.date.month}/${event.date.year} • ₹${event.totalBudget}'),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EventDetailsScreen(event: event)),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
