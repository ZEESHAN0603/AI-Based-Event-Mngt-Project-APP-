class Event {
  final String id;
  final String name;
  final String type;
  final DateTime date;
  final String location;
  final double totalBudget;
  final int? numGuests;
  final List<String> requiredServices;

  Event({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.location,
    required this.totalBudget,
    this.numGuests,
    this.requiredServices = const [],
  });
}
