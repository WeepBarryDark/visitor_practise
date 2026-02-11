/// Validation helper for common input validation
/// Provides reusable validation functions for forms and data input
class ValidationHelper {
  ValidationHelper._();

  /// Validate email format
  /// Supports international domains, plus signs, and TLDs of any length
  ///
  /// Examples of valid emails:
  /// - user@example.com
  /// - user+tag@gmail.com
  /// - user@example.co.uk
  /// - user.name@sub.domain.example.com
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    // RFC 5322 compliant email validation
    // Using regular string instead of raw string to properly handle single quote
    return RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    ).hasMatch(email);
  }

  /// Validate email and return error message if invalid
  /// Returns null if valid
  static String? validateEmail(String? email, {bool required = true}) {
    if (email == null || email.trim().isEmpty) {
      return required ? 'Email is required' : null;
    }

    if (!isValidEmail(email.trim())) {
      return 'Invalid email format';
    }

    return null;
  }

  /// Validate phone number (basic check)
  /// Accepts various formats: +1234567890, (123) 456-7890, 123-456-7890, etc.
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;

    // Remove common separators
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');

    // Check if it's all digits (with optional + prefix)
    return RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned);
  }

  /// Validate phone and return error message if invalid
  /// Returns null if valid
  static String? validatePhone(String? phone, {bool required = true}) {
    if (phone == null || phone.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }

    if (!isValidPhone(phone.trim())) {
      return 'Invalid phone number format';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Use validateRequired for required check
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  /// Validate URL format
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Validate URL and return error message if invalid
  static String? validateUrl(String? url, {bool required = true}) {
    if (url == null || url.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }

    if (!isValidUrl(url.trim())) {
      return 'Invalid URL format';
    }

    return null;
  }

  /// Validate numeric input
  static bool isNumeric(String value) {
    if (value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// Validate numeric and return error message if invalid
  static String? validateNumeric(String? value, String fieldName, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    if (!isNumeric(value.trim())) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  /// Validate integer input
  static bool isInteger(String value) {
    if (value.isEmpty) return false;
    return int.tryParse(value) != null;
  }

  /// Validate integer and return error message if invalid
  static String? validateInteger(String? value, String fieldName, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    if (!isInteger(value.trim())) {
      return '$fieldName must be a valid integer';
    }

    return null;
  }

  /// Validate numeric range
  static String? validateRange(
    String? value,
    double min,
    double max,
    String fieldName, {
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return '$fieldName must be a valid number';
    }

    if (numValue < min || numValue > max) {
      return '$fieldName must be between $min and $max';
    }

    return null;
  }

  /// Validate password strength
  /// Requirements:
  /// - At least 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one digit
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;

    // Check for uppercase
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Check for lowercase
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Check for digit
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    return true;
  }

  /// Validate password and return error message if weak
  static String? validatePassword(String? password, {bool required = true}) {
    if (password == null || password.isEmpty) {
      return required ? 'Password is required' : null;
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }

    return null;
  }

  /// Validate that two passwords match
  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate alphabetic characters only
  static bool isAlphabetic(String value) {
    if (value.isEmpty) return false;
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(value);
  }

  /// Validate alphanumeric characters only
  static bool isAlphanumeric(String value) {
    if (value.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value);
  }

  /// Validate credit card number (basic Luhn algorithm check)
  static bool isValidCreditCard(String cardNumber) {
    // Remove spaces and dashes
    final cleaned = cardNumber.replaceAll(RegExp(r'[\s\-]'), '');

    // Check if all digits
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) return false;

    // Check length (most cards are 13-19 digits)
    if (cleaned.length < 13 || cleaned.length > 19) return false;

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;

    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Validate date format (YYYY-MM-DD)
  static bool isValidDate(String date) {
    if (date.isEmpty) return false;

    try {
      final parsed = DateTime.parse(date);
      return parsed != null;
    } catch (e) {
      return false;
    }
  }

  /// Validate that date is not in the past
  static String? validateFutureDate(String? date, String fieldName) {
    if (date == null || date.trim().isEmpty) {
      return '$fieldName is required';
    }

    try {
      final parsed = DateTime.parse(date);
      if (parsed.isBefore(DateTime.now())) {
        return '$fieldName must be in the future';
      }
      return null;
    } catch (e) {
      return 'Invalid date format';
    }
  }

  /// Validate that date is not in the future
  static String? validatePastDate(String? date, String fieldName) {
    if (date == null || date.trim().isEmpty) {
      return '$fieldName is required';
    }

    try {
      final parsed = DateTime.parse(date);
      if (parsed.isAfter(DateTime.now())) {
        return '$fieldName must be in the past';
      }
      return null;
    } catch (e) {
      return 'Invalid date format';
    }
  }

  /// Validate postal/zip code (basic international support)
  static bool isValidPostalCode(String postalCode, {String? countryCode}) {
    if (postalCode.isEmpty) return false;

    // US ZIP code
    if (countryCode == 'US') {
      return RegExp(r'^\d{5}(-\d{4})?$').hasMatch(postalCode);
    }

    // UK postcode
    if (countryCode == 'GB') {
      return RegExp(r'^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$', caseSensitive: false)
          .hasMatch(postalCode);
    }

    // Canadian postal code
    if (countryCode == 'CA') {
      return RegExp(r'^[A-Z]\d[A-Z] ?\d[A-Z]\d$', caseSensitive: false)
          .hasMatch(postalCode);
    }

    // Australian postcode
    if (countryCode == 'AU') {
      return RegExp(r'^\d{4}$').hasMatch(postalCode);
    }

    // Generic: 3-10 alphanumeric characters
    return RegExp(r'^[A-Z0-9\s\-]{3,10}$', caseSensitive: false).hasMatch(postalCode);
  }

  /// Combine multiple validators
  /// Returns the first error message or null if all pass
  static String? combineValidators(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}
