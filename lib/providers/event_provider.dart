import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  String? _selectedEventId;
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  String? get selectedEventId => _selectedEventId;
  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Event? get selectedEvent =>
      _selectedEventId != null
          ? _events.cast<Event?>().firstWhere((e) => e?.id == _selectedEventId, orElse: () => null)
          : null;

  void selectEvent(String eventId) {
    _selectedEventId = (_selectedEventId == eventId) ? null : eventId;
    notifyListeners();
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await EventService.getEvents();
      _events = data.map((json) => Event.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load events';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createEvent(Map<String, dynamic> data) async {
    try {
      final result = await EventService.createEvent(data);
      if (result['statusCode'] == 201) {
        await fetchEvents();
        return true;
      }
      _error = result['detail'] ?? 'Failed to create event';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(String id, Map<String, dynamic> data) async {
    try {
      final result = await EventService.updateEvent(id, data);
      if (result['statusCode'] == 200) {
        await fetchEvents();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      final success = await EventService.deleteEvent(id);
      if (success) {
        if (_selectedEventId == id) _selectedEventId = null;
        await fetchEvents();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
