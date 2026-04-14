import 'package:flutter/material.dart';
import '../models/event.dart';

class EventProvider with ChangeNotifier {
  String? _selectedEventId;
  
  final List<Event> _events = [
    Event(
      id: 'event_1',
      name: 'Grand Wedding Gala',
      type: 'Wedding',
      date: DateTime(2023, 12, 15),
      location: 'City Palace, Downtown',
      totalBudget: 50000,
      numGuests: 500,
      requiredServices: ['venue', 'catering', 'photography', 'decoration'],
    ),
    Event(
      id: 'event_2',
      name: 'Corporate Annual Meet',
      type: 'College Events',
      date: DateTime(2024, 01, 20),
      location: 'Silicon Valley Convention Center',
      totalBudget: 25000,
      numGuests: 200,
      requiredServices: ['venue', 'catering', 'lighting'],
    ),
    Event(
      id: 'event_3',
      name: 'Birthday Bash',
      type: 'Birthday',
      date: DateTime(2024, 05, 10),
      location: 'Skyline Rooftop, Midtown',
      totalBudget: 5000,
      numGuests: 50,
      requiredServices: ['decoration', 'catering', 'music'],
    ),
  ];

  String? get selectedEventId => _selectedEventId;
  List<Event> get events => _events;

  Event? get selectedEvent => 
      _selectedEventId != null ? _events.firstWhere((e) => e.id == _selectedEventId) : null;

  void selectEvent(String eventId) {
    if (_selectedEventId == eventId) {
      _selectedEventId = null;
    } else {
      _selectedEventId = eventId;
    }
    notifyListeners();
  }
}
