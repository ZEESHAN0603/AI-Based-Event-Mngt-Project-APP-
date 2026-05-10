class Booking {
  final String id;
  final String eventId;
  final String vendorId;
  final String organizerId;
  final String bookingStatus;
  final double totalAmount;
  final String? notes;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.eventId,
    required this.vendorId,
    required this.organizerId,
    required this.bookingStatus,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      eventId: json['event_id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      organizerId: json['organizer_id'] ?? '',
      bookingStatus: json['booking_status'] ?? 'pending',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
