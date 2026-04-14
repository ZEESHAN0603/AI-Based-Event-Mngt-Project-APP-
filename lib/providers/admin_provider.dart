import 'package:flutter/material.dart';

enum AdminBookingStatus { pending, confirmed, rejected }

class AdminBooking {
  final String id;
  final String eventName;
  final String organizerName;
  final String vendorName;
  final DateTime date;
  AdminBookingStatus status;

  AdminBooking({
    required this.id,
    required this.eventName,
    required this.organizerName,
    required this.vendorName,
    required this.date,
    this.status = AdminBookingStatus.pending,
  });
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final int eventCount;
  bool isEnabled;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.eventCount,
    this.isEnabled = true,
  });
}

class AdminContent {
  final String id;
  final String title;
  final String description;
  final String source;
  final DateTime date;
  bool isApproved;

  AdminContent({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    required this.date,
    this.isApproved = false,
  });
}

class AdminProvider with ChangeNotifier {
  final List<AdminBooking> _bookings = [
    AdminBooking(id: 'b1', eventName: 'Wedding Gala', organizerName: 'John Doe', vendorName: 'Elite Catering', date: DateTime(2023, 12, 15), status: AdminBookingStatus.confirmed),
    AdminBooking(id: 'b2', eventName: 'Corporate Meet', organizerName: 'Sarah Smith', vendorName: 'Grand Venue', date: DateTime(2024, 01, 20), status: AdminBookingStatus.pending),
    AdminBooking(id: 'b3', eventName: 'Birthday Bash', organizerName: 'Mike Johnson', vendorName: 'Sparkle Decor', date: DateTime(2024, 02, 10), status: AdminBookingStatus.pending),
    AdminBooking(id: 'b4', eventName: 'Engagement', organizerName: 'Emma Watson', vendorName: 'Photo Pro', date: DateTime(2024, 03, 05), status: AdminBookingStatus.rejected),
    AdminBooking(id: 'b5', eventName: 'Product Launch', organizerName: 'Robert Brown', vendorName: 'LED Walls Inc', date: DateTime(2024, 04, 12), status: AdminBookingStatus.confirmed),
  ];

  final List<AdminUser> _users = [
    AdminUser(id: 'u1', name: 'John Doe', email: 'john@example.com', eventCount: 3),
    AdminUser(id: 'u2', name: 'Sarah Smith', email: 'sarah@example.com', eventCount: 1),
    AdminUser(id: 'u3', name: 'Mike Johnson', email: 'mike@example.com', eventCount: 5),
    AdminUser(id: 'u4', name: 'Emma Watson', email: 'emma@example.com', eventCount: 2),
  ];

  final List<AdminContent> _contents = [
    AdminContent(id: 'c1', title: 'Top 10 Wedding Venues 2023', description: 'Discover the most sought-after wedding locations of the year.', source: 'Wedding Weekly', date: DateTime(2023, 11, 01), isApproved: true),
    AdminContent(id: 'c2', title: 'Planning Your Corporate Event', description: 'Expert tips for organizing a successful business gathering.', source: 'Event Pro', date: DateTime(2023, 11, 15), isApproved: false),
    AdminContent(id: 'c3', title: 'How to Choose a Photographer', description: 'What to look for when hiring a professional for your big day.', source: 'Visual Arts', date: DateTime(2023, 12, 01), isApproved: true),
    AdminContent(id: 'c4', title: 'Catering Trends for 2024', description: 'The hottest menu items and service styles for upcoming events.', source: 'Foodie Mag', date: DateTime(2023, 12, 10), isApproved: false),
    AdminContent(id: 'c5', title: 'Decorating on a Budget', description: 'Elegant and affordable ideas for any celebration.', source: 'Style Files', date: DateTime(2024, 01, 05), isApproved: true),
  ];

  List<AdminBooking> get bookings => _bookings;
  List<AdminUser> get users => _users;
  List<AdminContent> get contents => _contents;

  void updateBookingStatus(String id, AdminBookingStatus status) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index].status = status;
      notifyListeners();
    }
  }

  void toggleUserStatus(String id) {
    final index = _users.indexWhere((u) => u.id == id);
    if (index != -1) {
      _users[index].isEnabled = !_users[index].isEnabled;
      notifyListeners();
    }
  }

  void updateContentStatus(String id, bool approved) {
    final index = _contents.indexWhere((c) => c.id == id);
    if (index != -1) {
      _contents[index].isApproved = approved;
      notifyListeners();
    }
  }

  void addContent(String title, String description, String source) {
    final newContent = AdminContent(
      id: 'c${_contents.length + 1}',
      title: title,
      description: description,
      source: source,
      date: DateTime.now(),
      isApproved: false,
    );
    _contents.insert(0, newContent);
    notifyListeners();
  }

  void removeContent(String id) {
    _contents.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // Activity Log
  final List<String> _activityLog = [
    'Approved vendor: Elite Catering Services',
    'New user registration: Robert Brown',
    'Confirmed booking for Robert Brown',
    'Rejected content: Decorating on a Budget',
    'Updated tax settings for the platform',
  ];

  List<String> get activityLog => _activityLog;
}
