import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:visitor_practise/services/helper/app_logger.dart';

/// Network connectivity service
/// Monitors and reports network status changes
class NetworkService {
  NetworkService._();

  static final Connectivity _connectivity = Connectivity();
  static StreamController<bool>? _connectionStatusController;
  static bool _isConnected = true;

  /// Initialize network monitoring
  static Future<void> initialize() async {
    _connectionStatusController = StreamController<bool>.broadcast();

    // Check initial connection
    _isConnected = await isConnected();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasConnected = _isConnected;

      // Check if any connection is available
      _isConnected = results.any((result) => result != ConnectivityResult.none);

      AppLogger.network(
        _isConnected ? 'Connection restored' : 'Connection lost',
        method: 'CONNECTIVITY',
      );

      // Notify listeners if status changed
      if (wasConnected != _isConnected) {
        _connectionStatusController?.add(_isConnected);
      }
    });
  }

  /// Check if device is connected to internet
  static Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      AppLogger.error('Failed to check connectivity', e, null, 'NetworkService');
      return false;
    }
  }

  /// Get current connection status synchronously (uses cached value)
  static bool get isOnline => _isConnected;

  /// Stream of connection status changes
  static Stream<bool> get onConnectivityChanged {
    if (_connectionStatusController == null) {
      initialize();
    }
    return _connectionStatusController!.stream;
  }

  /// Get current connectivity type
  static Future<String> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty || results.first == ConnectivityResult.none) {
        return 'offline';
      }

      // Return first active connection type
      final result = results.first;
      switch (result) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.mobile:
          return 'Mobile Data';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        default:
          return 'Unknown';
      }
    } catch (e) {
      AppLogger.error('Failed to get connection type', e, null, 'NetworkService');
      return 'unknown';
    }
  }

  /// Dispose resources
  static void dispose() {
    _connectionStatusController?.close();
    _connectionStatusController = null;
  }
}
