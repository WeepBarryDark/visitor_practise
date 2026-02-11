import 'package:visitor_practise/services/api_service.dart';
import 'package:flutter/material.dart';

/// Notification Service for sending SMS and Email notifications
/// Handles visitor sign-in/sign-out notifications and delivery alerts
///
/// ============================================================================
/// NOTIFICATION RECIPIENTS (IMPORTANT):
/// ============================================================================
///
/// 1. VISITOR SIGN-IN/SIGN-OUT:
///    ✅ Notifications are sent to the PERSON BEING VISITED (Person Visiting)
///    ❌ NOT sent to site supervisor
///    Example: John visits to see Mary → Mary receives notification
///
/// 2. DELIVERY ARRIVAL:
///    ✅ Notifications are sent to the SITE SUPERVISOR
///    ❌ NOT sent to the delivery recipient
///    Example: Delivery arrives at Site A → Site A supervisor is notified
///
/// 3. ADMIN DASHBOARD SETTINGS:
///    - "Person Visiting SMS/Email" → Controls visitor notifications
///    - "Delivery SMS/Email" → Controls delivery notifications
///
/// ============================================================================
class NotificationService {
  NotificationService._();

  /// Send SMS notification
  ///
  /// Example usage:
  /// ```dart
  /// await NotificationService.sendSMS(
  ///   userId: '23',
  ///   phone: '+1234567890',
  ///   message: 'John Doe has signed in to visit you.',
  ///   authToken: token,
  /// );
  /// ```
  static Future<bool> sendSMS({
    required String userId,
    required String phone,
    required String message,
    required String authToken,
  }) async {
    try {
      return await ApiService.sendSMS(
        token: authToken,
        userId: userId,
        mobile: phone,
        message: message,
      );
    } catch (e) {
      debugPrint('Error sending SMS: $e');
      return false;
    }
  }

  /// Send Email notification
  ///
  /// Example usage:
  /// ```dart
  /// await NotificationService.sendEmail(
  ///   userId: '23',
  ///   name: 'John Doe',
  ///   email: 'supervisor@example.com',
  ///   phone: '+1234567890',
  ///   message: 'John Doe has arrived.',
  ///   authToken: token,
  /// );
  /// ```
  static Future<bool> sendEmail({
    required String userId,
    required String name,
    required String email,
    String? phone,
    required String message,
    required String authToken,
  }) async {
    try {
      return await ApiService.sendEmail(
        token: authToken,
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        message: message,
      );
    } catch (e) {
      debugPrint('Error sending Email: $e');
      return false;
    }
  }

  /// Build visitor sign-in notification message
  static String buildSignInMessage({
    required String visitorName,
    required String visitorCompany,
    required String siteName,
  }) {
    return '$visitorName from $visitorCompany has signed in at $siteName and is waiting to see you.';
  }

  /// Build visitor sign-in email body
  static String buildSignInEmail({
    required String visitorName,
    required String visitorCompany,
    required String visitorEmail,
    required String visitorPhone,
    required String siteName,
    required String signInTime,
  }) {
    return '''
Hello,

$visitorName from $visitorCompany has signed in at $siteName.

Visitor Details:
- Name: $visitorName
- Company: $visitorCompany
- Email: $visitorEmail
- Phone: $visitorPhone
- Sign In Time: $signInTime

Please meet them at the reception.

This is an automated message from the Visitor Management System.
''';
  }

  /// Build visitor sign-out notification message
  static String buildSignOutMessage({
    required String visitorName,
    required String siteName,
  }) {
    return '$visitorName has signed out from $siteName.';
  }

  /// Build visitor sign-out email body
  static String buildSignOutEmail({
    required String visitorName,
    required String visitorCompany,
    required String siteName,
    required String signOutTime,
    required String duration,
  }) {
    return '''
Hello,

$visitorName from $visitorCompany has signed out from $siteName.

Visit Summary:
- Name: $visitorName
- Company: $visitorCompany
- Sign Out Time: $signOutTime
- Visit Duration: $duration

Thank you for your visit.

This is an automated message from the Visitor Management System.
''';
  }

  /// Build delivery arrival notification message
  static String buildDeliveryArrivalMessage({
    required String deliveryCompany,
    required String recipientName,
  }) {
    return 'A delivery from $deliveryCompany has arrived for $recipientName.';
  }

  /// Build delivery arrival email body
  static String buildDeliveryArrivalEmail({
    required String deliveryCompany,
    required String recipientName,
    required String siteName,
    required String arrivalTime,
    String? details,
  }) {
    return '''
Hello $recipientName,

A delivery has arrived for you at $siteName.

Delivery Details:
- Delivery Company: $deliveryCompany
- Recipient: $recipientName
- Arrival Time: $arrivalTime
${details != null && details.isNotEmpty ? '- Details: $details' : ''}

Please collect your delivery from the reception.

This is an automated message from the Visitor Management System.
''';
  }

  /// Send visitor sign-in notifications (SMS + Email)
  ///
  /// **IMPORTANT:** Notifications are sent to the PERSON BEING VISITED (Person Visiting),
  /// NOT to the site supervisor.
  ///
  /// Example: If John Doe visits to see Mary Smith, notifications are sent to Mary Smith.
  static Future<void> sendSignInNotifications({
    required String personVisitingId,        // Person being visited's ID (user_id for API)
    required String personVisitingName,      // Person being visited
    required String personVisitingEmail,     // Person being visited's email
    required String personVisitingPhone,     // Person being visited's phone
    required String visitorName,
    required String visitorCompany,
    required String visitorEmail,
    required String visitorPhone,
    required String siteName,
    required String signInTime,
    required String authToken,
    bool sendSms = true,
    bool sendEmail = true,
  }) async {
    try {
      // Send SMS to the person being visited (NOT site supervisor)
      if (sendSms && personVisitingPhone.isNotEmpty) {
        final smsMessage = buildSignInMessage(
          visitorName: visitorName,
          visitorCompany: visitorCompany,
          siteName: siteName,
        );

        await sendSMS(
          userId: personVisitingId,
          phone: personVisitingPhone,
          message: smsMessage,
          authToken: authToken,
        );
      }

      // Send Email to the person being visited (NOT site supervisor)
      if (sendEmail && personVisitingEmail.isNotEmpty) {
        final emailBody = buildSignInEmail(
          visitorName: visitorName,
          visitorCompany: visitorCompany,
          visitorEmail: visitorEmail,
          visitorPhone: visitorPhone,
          siteName: siteName,
          signInTime: signInTime,
        );

        await NotificationService.sendEmail(
          userId: personVisitingId,
          name: personVisitingName,
          email: personVisitingEmail,
          phone: personVisitingPhone,
          message: emailBody,
          authToken: authToken,
        );
      }
    } catch (e) {
      debugPrint('Error sending sign-in notifications: $e');
    }
  }

  /// Send visitor sign-out notifications
  ///
  /// **IMPORTANT:** Notifications are sent to the PERSON WHO WAS VISITED (Person Visiting),
  /// NOT to the site supervisor.
  static Future<void> sendSignOutNotifications({
    required String personVisitingId,        // Person who was visited's ID (user_id for API)
    required String personVisitingName,      // Person who was visited
    required String personVisitingEmail,
    required String personVisitingPhone,
    required String visitorName,
    required String visitorCompany,
    required String siteName,
    required String signOutTime,
    required String duration,
    required String authToken,
    bool sendSms = true,
    bool sendEmail = true,
  }) async {
    try {
      // Send SMS to person who was visited
      if (sendSms && personVisitingPhone.isNotEmpty) {
        final smsMessage = buildSignOutMessage(
          visitorName: visitorName,
          siteName: siteName,
        );

        await sendSMS(
          userId: personVisitingId,
          phone: personVisitingPhone,
          message: smsMessage,
          authToken: authToken,
        );
      }

      // Send Email to person who was visited
      if (sendEmail && personVisitingEmail.isNotEmpty) {
        final emailBody = buildSignOutEmail(
          visitorName: visitorName,
          visitorCompany: visitorCompany,
          siteName: siteName,
          signOutTime: signOutTime,
          duration: duration,
        );

        await NotificationService.sendEmail(
          userId: personVisitingId,
          name: personVisitingName,
          email: personVisitingEmail,
          phone: personVisitingPhone,
          message: emailBody,
          authToken: authToken,
        );
      }
    } catch (e) {
      debugPrint('Error sending sign-out notifications: $e');
    }
  }

  /// Send delivery arrival notifications
  ///
  /// **IMPORTANT:** Notifications are sent to the SITE SUPERVISOR,
  /// NOT to the delivery recipient. The "recipient" parameters below refer to
  /// the site supervisor who should be notified about delivery arrivals.
  ///
  /// Example: When a delivery arrives at Site A, the Site A supervisor is notified.
  static Future<void> sendDeliveryNotifications({
    required String supervisorId,       // Site supervisor's ID (user_id for API)
    required String supervisorName,     // Site supervisor name
    required String supervisorEmail,    // Site supervisor email
    required String supervisorPhone,    // Site supervisor phone
    required String deliveryCompany,
    required String siteName,
    required String arrivalTime,
    required String authToken,
    String? details,
    bool sendSms = true,
    bool sendEmail = true,
  }) async {
    try {
      // Send SMS to site supervisor (NOT delivery recipient)
      if (sendSms && supervisorPhone.isNotEmpty) {
        final smsMessage = buildDeliveryArrivalMessage(
          deliveryCompany: deliveryCompany,
          recipientName: supervisorName,
        );

        await sendSMS(
          userId: supervisorId,
          phone: supervisorPhone,
          message: smsMessage,
          authToken: authToken,
        );
      }

      // Send Email to site supervisor (NOT delivery recipient)
      if (sendEmail && supervisorEmail.isNotEmpty) {
        final emailBody = buildDeliveryArrivalEmail(
          deliveryCompany: deliveryCompany,
          recipientName: supervisorName,
          siteName: siteName,
          arrivalTime: arrivalTime,
          details: details,
        );

        await NotificationService.sendEmail(
          userId: supervisorId,
          name: supervisorName,
          email: supervisorEmail,
          phone: supervisorPhone,
          message: emailBody,
          authToken: authToken,
        );
      }
    } catch (e) {
      debugPrint('Error sending delivery notifications: $e');
    }
  }
}
