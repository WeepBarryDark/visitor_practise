import 'dart:typed_data';

class BadgeGenerator {
  final String visitorId;  // Unique ID for QR code
  final String? fullName;
  final String? email;
  final String? phone;
  final String? workType;
  final String? company;
  final String? address;
  final String? supervisor;
  final String? signInTime;
  final String siteName;
  final Uint8List? clientLogoBytes;  // Custom client logo bytes (overrides default)
  final Uint8List? visitorPhotoBytes;  // Visitor photo captured during sign-in

  // Field configurations - which fields to show on badge
  final bool showFullName;
  final bool showEmail;
  final bool showPhone;
  final bool showWorkType;
  final bool showCompany;
  final bool showAddress;
  final bool showSupervisor;
  final bool showSignInTime;
  final bool showVisitorPhoto;

  const BadgeGenerator({
    required this.visitorId,
    this.fullName,
    this.email,
    this.phone,
    this.workType,
    this.company,
    this.address,
    this.supervisor,
    this.signInTime,
    required this.siteName,
    this.clientLogoBytes,
    this.visitorPhotoBytes,
    // Default to show all fields if not specified
    this.showFullName = true,
    this.showEmail = true,
    this.showPhone = true,
    this.showWorkType = true,
    this.showCompany = true,
    this.showAddress = true,
    this.showSupervisor = true,
    this.showSignInTime = true,
    this.showVisitorPhoto = true,
  });
}
