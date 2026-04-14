import 'package:flutter/material.dart';
import '../models/task_item.dart';

class TaskProvider with ChangeNotifier {
  final List<TaskItem> _tasks = [
    TaskItem(id: 't1', name: 'Book a Venue', eventId: 'event_1'),
    TaskItem(id: 't2', name: 'Send Invitations', eventId: 'event_1'),
    TaskItem(id: 't3', name: 'Hire Photographer', eventId: 'event_1'),
  ];

  List<TaskItem> getTasksForEvent(String eventId) {
    return _tasks.where((t) => t.eventId == eventId).toList();
  }

  void addTask(String name, String eventId) {
    final newTask = TaskItem(
      id: 'task_${DateTime.now()}',
      name: name,
      eventId: eventId,
    );
    _tasks.add(newTask);
    notifyListeners();
  }

  void addVendorTask(String eventId, String vendorId, String vendorName, String categoryName) {
    String taskName = "Finalize ₹vendorName (₹categoryName)";
    
    // Custom names for specific categories
    if (categoryName.toLowerCase().contains('catering')) {
      taskName = "Confirm catering arrangements";
    } else if (categoryName.toLowerCase().contains('photo')) {
      taskName = "Finalize photographer";
    } else if (categoryName.toLowerCase().contains('venue')) {
      taskName = "Secure venue booking";
    }

    // Don't add if already exists for this vendor and event
    if (_tasks.any((t) => t.eventId == eventId && t.vendorId == vendorId)) return;

    final newTask = TaskItem(
      id: 'task_${DateTime.now()}',
      name: taskName,
      eventId: eventId,
      vendorId: vendorId,
    );
    _tasks.add(newTask);
    notifyListeners();
  }

  void removeVendorTask(String eventId, String vendorId) {
    _tasks.removeWhere((t) => t.eventId == eventId && t.vendorId == vendorId);
    notifyListeners();
  }

  void toggleTaskStatus(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].status = _tasks[index].status == TaskStatus.completed
          ? TaskStatus.pending
          : TaskStatus.completed;
      notifyListeners();
    }
  }
}
