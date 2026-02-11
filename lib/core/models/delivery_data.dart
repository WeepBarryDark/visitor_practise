/// Delivery Data Model - Information for package/delivery logging
///
/// **PURPOSE:**
/// Stores delivery information when couriers drop off packages at the site.
/// Notifies the recipient that a delivery has arrived.
///
/// **WHY WE NEED THIS:**
/// - Track deliveries arriving at site
/// - Notify recipients of package arrival
/// - Maintain delivery records
///
/// **WHERE IT'S USED:**
/// - Deliveries Page: Collect delivery information
/// - API: Submit delivery record
/// - Notifications: Email recipient about delivery
///
/// **DATA FLOW:**
/// ```
/// Delivery Form → DeliveryData → API Submission → Email Notification
/// ```
class DeliveryData {
  /// Name of the delivery company/courier (required)
  final String deliveryCompany;

  /// Name of the person receiving the package (required)
  final String recipientName;

  /// Contact information for recipient (email or phone) (required)
  final String recipientContact;

  /// Additional details about the delivery (optional)
  final String? details;

  /// Timestamp of delivery arrival (ISO 8601 format)
  final String timestamp;

  /// Site ID where delivery was received
  final String siteId;

  /// Delivery ID returned from API (after submission)
  final String? deliveryId;

  /// Create DeliveryData with all fields
  const DeliveryData({
    required this.deliveryCompany,
    required this.recipientName,
    required this.recipientContact,
    required this.timestamp,
    required this.siteId,
    this.details,
    this.deliveryId,
  });

  /// Create a copy with updated fields
  DeliveryData copyWith({
    String? deliveryCompany,
    String? recipientName,
    String? recipientContact,
    String? details,
    String? timestamp,
    String? siteId,
    String? deliveryId,
  }) {
    return DeliveryData(
      deliveryCompany: deliveryCompany ?? this.deliveryCompany,
      recipientName: recipientName ?? this.recipientName,
      recipientContact: recipientContact ?? this.recipientContact,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      siteId: siteId ?? this.siteId,
      deliveryId: deliveryId ?? this.deliveryId,
    );
  }

  /// Convert to JSON (for API submission)
  Map<String, dynamic> toJson() {
    return {
      'delivery_company': deliveryCompany,
      'recipient_name': recipientName,
      'recipient_contact': recipientContact,
      'details': details,
      'timestamp': timestamp,
      'site_id': siteId,
      if (deliveryId != null) 'delivery_id': deliveryId,
    };
  }

  /// Create from JSON (from API response)
  factory DeliveryData.fromJson(Map<String, dynamic> json) {
    return DeliveryData(
      deliveryCompany: json['delivery_company']?.toString() ?? '',
      recipientName: json['recipient_name']?.toString() ?? '',
      recipientContact: json['recipient_contact']?.toString() ?? '',
      details: json['details']?.toString(),
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      siteId: json['site_id']?.toString() ?? '',
      deliveryId: json['delivery_id']?.toString(),
    );
  }

  /// Check if delivery data is complete for submission
  bool get isComplete {
    return deliveryCompany.isNotEmpty &&
        recipientName.isNotEmpty &&
        recipientContact.isNotEmpty &&
        siteId.isNotEmpty;
  }

  /// Check if recipient contact looks like an email
  bool get isEmailContact {
    return recipientContact.contains('@');
  }

  /// Check if recipient contact looks like a phone number
  bool get isPhoneContact {
    return RegExp(r'^\+?[0-9\s\-()]+$').hasMatch(recipientContact);
  }

  @override
  String toString() {
    return 'DeliveryData(company: $deliveryCompany, recipient: $recipientName, contact: $recipientContact)';
  }
}
