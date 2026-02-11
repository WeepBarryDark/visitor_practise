/// Unified API exception handling for consistent error management
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;
  final dynamic originalError;

  ApiException(
    this.message, {
    this.statusCode,
    required this.type,
    this.originalError,
  });

  @override
  String toString() {
    final statusStr = statusCode != null ? ' (Status: $statusCode)' : '';
    return 'ApiException: $message$statusStr [Type: ${type.name}]';
  }

  /// Get user-friendly error message
  String get userMessage {
    switch (type) {
      case ApiErrorType.network:
        return 'Cannot connect to server. Please check your internet connection.';
      case ApiErrorType.timeout:
        return 'Request timed out. Please try again.';
      case ApiErrorType.unauthorized:
        return 'Session expired. Please sign in again.';
      case ApiErrorType.validation:
        return message; // Use specific validation message
      case ApiErrorType.server:
        return 'Server error occurred. Please try again later.';
      case ApiErrorType.notFound:
        return 'The requested resource was not found.';
      case ApiErrorType.unknown:
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

/// Types of API errors for categorization
enum ApiErrorType {
  /// Network connectivity issues
  network,

  /// Request timeout
  timeout,

  /// Authentication/authorization failures (401, 403)
  unauthorized,

  /// Validation errors (400, 422)
  validation,

  /// Server errors (500, 502, 503)
  server,

  /// Resource not found (404)
  notFound,

  /// Unknown or uncategorized errors
  unknown,
}

/// Helper to create ApiException from HTTP status code
class ApiExceptionFactory {
  ApiExceptionFactory._();

  /// Create exception based on status code
  static ApiException fromStatusCode(int statusCode, String message) {
    ApiErrorType type;

    if (statusCode >= 500) {
      type = ApiErrorType.server;
    } else if (statusCode == 404) {
      type = ApiErrorType.notFound;
    } else if (statusCode == 401 || statusCode == 403) {
      type = ApiErrorType.unauthorized;
    } else if (statusCode == 400 || statusCode == 422) {
      type = ApiErrorType.validation;
    } else {
      type = ApiErrorType.unknown;
    }

    return ApiException(
      message,
      statusCode: statusCode,
      type: type,
    );
  }

  /// Create exception from generic error
  static ApiException fromError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return ApiException(
        'Network connection failed',
        type: ApiErrorType.network,
        originalError: error,
      );
    }

    // Timeout errors
    if (errorString.contains('timeout')) {
      return ApiException(
        'Request timed out',
        type: ApiErrorType.timeout,
        originalError: error,
      );
    }

    // Unknown error
    return ApiException(
      error.toString(),
      type: ApiErrorType.unknown,
      originalError: error,
    );
  }
}
