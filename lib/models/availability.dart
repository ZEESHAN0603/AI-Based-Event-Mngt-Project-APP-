class BlockedDate {
  final String id;
  final String vendorId;
  final DateTime blockedDate;
  final String status;
  final DateTime createdAt;

  BlockedDate({
    required this.id,
    required this.vendorId,
    required this.blockedDate,
    required this.status,
    required this.createdAt,
  });

  factory BlockedDate.fromJson(Map<String, dynamic> json) {
    return BlockedDate(
      id: json['id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      blockedDate: DateTime.parse(json['blocked_date']),
      status: json['status'] ?? 'blocked',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
