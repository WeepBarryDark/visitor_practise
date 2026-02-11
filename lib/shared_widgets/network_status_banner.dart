import 'package:flutter/material.dart';
import 'package:visitor_practise/services/network_service.dart';
import 'package:visitor_practise/core/theme/app_theme.dart';

/// Network status banner that shows at the top when offline
/// Automatically displays/hides based on connectivity changes
class NetworkStatusBanner extends StatefulWidget {
  final Widget child;

  const NetworkStatusBanner({
    super.key,
    required this.child,
  });

  @override
  State<NetworkStatusBanner> createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner> {
  bool _isOnline = true;
  String _connectionType = '';

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
    _listenToConnectivityChanges();
  }

  Future<void> _checkInitialStatus() async {
    final isConnected = await NetworkService.isConnected();
    final connectionType = await NetworkService.getConnectionType();

    if (mounted) {
      setState(() {
        _isOnline = isConnected;
        _connectionType = connectionType;
      });
    }
  }

  void _listenToConnectivityChanges() {
    NetworkService.onConnectivityChanged.listen((isConnected) async {
      final connectionType = await NetworkService.getConnectionType();

      if (mounted) {
        setState(() {
          _isOnline = isConnected;
          _connectionType = connectionType;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Offline banner
        if (!_isOnline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.red.shade700,
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No Internet Connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'System is offline. Please check your network connection.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'OFFLINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Connection restored banner removed (per user request - looked ugly)

        // Main content
        Expanded(child: widget.child),
      ],
    );
  }
}
