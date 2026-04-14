enum TaskStatus {
  pending,
  completed,
}

class TaskItem {
  final String id;
  final String name;
  final String eventId;
  final String? vendorId;
  TaskStatus status;

  TaskItem({
    required this.id,
    required this.name,
    required this.eventId,
    this.vendorId,
    this.status = TaskStatus.pending,
  });
}
