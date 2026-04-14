import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_item.dart';
import 'package:evora/widgets/glass_container.dart';

class EventChecklistScreen extends StatefulWidget {
  const EventChecklistScreen({super.key});

  @override
  State<EventChecklistScreen> createState() => _EventChecklistScreenState();
}

class _EventChecklistScreenState extends State<EventChecklistScreen> {
  final TextEditingController _taskController = TextEditingController();

  void _showAddTaskDialog(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: TextField(
          controller: _taskController,
          decoration: const InputDecoration(hintText: 'Task Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                context.read<TaskProvider>().addTask(_taskController.text, eventId);
                _taskController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final eventId = eventProvider.selectedEventId;
    final taskProvider = context.watch<TaskProvider>();

    if (eventId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Checklist')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, size: 64, ),
              const SizedBox(height: 16),
              const Text('No event selected.', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Please select an event from the dashboard.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final tasks = taskProvider.getTasksForEvent(eventId);
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).toList();
    final pendingTasks = tasks.where((t) => t.status == TaskStatus.pending).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Checklist'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(tasks.length, completedTasks.length),
          const SizedBox(height: 24),
          if (pendingTasks.isNotEmpty) ...[
            const Text('Pending Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...pendingTasks.map((task) => _buildTaskItem(context, task, taskProvider)),
          ],
          if (completedTasks.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Completed Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...completedTasks.map((task) => _buildTaskItem(context, task, taskProvider)),
          ],
          if (tasks.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Text('No tasks found for this event.'),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, eventId),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_task),
      ),
    );
  }

  Widget _buildSummaryCard(int total, int completed) {
    final progress = total > 0 ? completed / total : 0.0;

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progress', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('₹completed / ₹total Tasks',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskItem task, TaskProvider provider) {
    final isCompleted = task.status == TaskStatus.completed;

    return GlassContainer(
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (_) => provider.toggleTaskStatus(task.id),
        ),
        title: Text(
          task.name,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
        ),
        trailing: task.vendorId != null ? const Icon(Icons.store, size: 16, ) : null,
      ),
    );
  }
}
