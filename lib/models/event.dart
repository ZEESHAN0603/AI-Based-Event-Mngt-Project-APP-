class Event {
  final String id;
  String name;
  final String type;
  final DateTime date;
  final String location;
  double totalBudget;
  final int? numGuests;
  final String? description;

  Event({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.location,
    required this.totalBudget,
    this.numGuests,
    this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      name: json['event_name'] ?? '',
      type: json['event_type'] ?? '',
      date: DateTime.parse(json['event_date']),
      location: json['location'] ?? '',
      totalBudget: (json['budget'] ?? 0).toDouble(),
      numGuests: json['guest_count'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_name': name,
      'event_type': type,
      'event_date': date.toIso8601String(),
      'location': location,
      'budget': totalBudget,
      'guest_count': numGuests ?? 0,
      'description': description ?? '',
    };
  }
}
