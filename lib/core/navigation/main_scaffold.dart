import 'package:flutter/material.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String title;

  const AppShell({
    super.key,
    required this.child,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),

      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Worx Companion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Visitor Management', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: () {
                  Navigator.pop(context);
                  _handleLogout(context);
                },
              ),
            ],
          ),
        ),
      ),

      body: child,
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), //close the sidebar
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              Navigator.pop(context); //close the sidebar

              showDialog(
                context: context,
                barrierDismissible: false, //click backgaround - cannot close this 
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final authToken = await SecureStorageService.getAuthToken();
                if (authToken != null && authToken.isNotEmpty) {
                  try {
                    await ApiService.revokeVisitorToken(authToken);
                  } 
                  catch (e) {
                     debugPrint('revoke visitor token error $e');
                  }
                }
                await SecureStorageService.clearAll();
              } catch (_) {
                await SecureStorageService.clearAll();
              }

              rootNavigator.pop();
              await Future.delayed(const Duration(milliseconds: 100));

              rootNavigator.pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
