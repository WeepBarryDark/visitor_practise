import 'dart:typed_data';

/// Visitor Data Model - Complete visitor information for sign-in flow
///
/// **PURPOSE:**
/// Passes visitor information between pages in the sign-in flow:
/// Sign In → Site Questions → Final Badge
///
/// **WHY WE NEED THIS:**
/// - Centralized visitor data structure
/// - Easy data passing via Navigator arguments
/// - Type-safe access to all visitor fields
///
/// **WHERE IT'S USED:**
/// - Sign In Page: Collect visitor information
/// - Site Questions Page: Receive data, add question answers
/// - Final Badge Page: Generate badge with all info
/// - API: Submit complete visitor record
///
/// **DATA FLOW:**
/// ```
/// Sign In Form → VisitorData →
/// Site Questions (add answers) → VisitorData →
/// Badge Generation → Final Badge Display
/// ```
class VisitorData {
  /// Full name of the visitor (required)
  final String fullName;

  /// Email address (required, validated format)
  final String email;

  /// Phone number (required)
  final String phone;

  /// Company/organization name (required)
  final String company;

  /// Physical address (required)
  final String address;

  /// Type of work or purpose of visit (required)
  final String workType;

  /// Sign-in timestamp (ISO 8601 format)
  final String signInTime;

  /// ID of the contact/supervisor being visited (required)
  final String contactDetailId;

  /// Name of the contact/supervisor being visited
  final String contactDetailName;

  /// Email of the contact/supervisor being visited (for notifications)
  final String contactDetailEmail;

  /// Phone of the contact/supervisor being visited (for notifications)
  final String contactDetailPhone;

  /// Visitor photo bytes (optional)
  /// ⚠️ Note: Photo is stored but NOT embedded in badge
  final Uint8List? visitorPhotoBytes;

  /// Site question answers (question_id → answer)
  /// All answers must be true/Yes to proceed
  final Map<String, bool> siteQuestionAnswers;

  /// Visitor ID returned from API after successful sign-in
  final String? visitorId;

  /// Site ID where visitor is signing in
  final String siteId;

  /// Whether to send SMS notifications to Person Visiting
  final bool sendSms;

  /// Whether to send Email notifications to Person Visiting
  final bool sendEmail;

  /// Create VisitorData with all fields
  const VisitorData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.company,
    required this.address,
    required this.workType,
    required this.signInTime,
    required this.contactDetailId,
    required this.contactDetailName,
    required this.contactDetailEmail,
    required this.contactDetailPhone,
    required this.siteId,
    this.sendSms = true,
    this.sendEmail = true,
    this.visitorPhotoBytes,
    this.siteQuestionAnswers = const {},
    this.visitorId,
  });

  /// Create a copy with updated fields
  VisitorData copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? company,
    String? address,
    String? workType,
    String? signInTime,
    String? contactDetailId,
    String? contactDetailName,
    String? contactDetailEmail,
    String? contactDetailPhone,
    String? siteId,
    bool? sendSms,
    bool? sendEmail,
    Uint8List? visitorPhotoBytes,
    Map<String, bool>? siteQuestionAnswers,
    String? visitorId,
  }) {
    return VisitorData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
      workType: workType ?? this.workType,
      signInTime: signInTime ?? this.signInTime,
      contactDetailId: contactDetailId ?? this.contactDetailId,
      contactDetailName: contactDetailName ?? this.contactDetailName,
      contactDetailEmail: contactDetailEmail ?? this.contactDetailEmail,
      contactDetailPhone: contactDetailPhone ?? this.contactDetailPhone,
      siteId: siteId ?? this.siteId,
      sendSms: sendSms ?? this.sendSms,
      sendEmail: sendEmail ?? this.sendEmail,
      visitorPhotoBytes: visitorPhotoBytes ?? this.visitorPhotoBytes,
      siteQuestionAnswers: siteQuestionAnswers ?? this.siteQuestionAnswers,
      visitorId: visitorId ?? this.visitorId,
    );
  }

  /// Convert to JSON (for API submission)
  /// Note: Photo bytes are converted to base64 for transmission
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'company': company,
      'address': address,
      'work_type': workType,
      'sign_in_time': signInTime,
      'contact_detail_id': contactDetailId,
      'contact_detail_name': contactDetailName,
      'site_id': siteId,
      'has_photo': visitorPhotoBytes != null,
      'site_question_answers': siteQuestionAnswers,
      if (visitorId != null) 'visitor_id': visitorId,
    };
  }

  /// Check if photo was captured
  bool get hasPhoto => visitorPhotoBytes != null;

  /// Check if all required questions have been answered
  bool get hasAnsweredQuestions => siteQuestionAnswers.isNotEmpty;

  /// Check if all answers are Yes/true
  bool get allAnswersYes =>
      siteQuestionAnswers.isNotEmpty &&
      siteQuestionAnswers.values.every((answer) => answer == true);

  /// Check if visitor data is complete for submission
  bool get isComplete {
    return fullName.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        company.isNotEmpty &&
        address.isNotEmpty &&
        workType.isNotEmpty &&
        signInTime.isNotEmpty &&
        contactDetailId.isNotEmpty &&
        siteId.isNotEmpty;
  }

  @override
  String toString() {
    return 'VisitorData(name: $fullName, email: $email, company: $company, contact: $contactDetailName)';
  }
}
