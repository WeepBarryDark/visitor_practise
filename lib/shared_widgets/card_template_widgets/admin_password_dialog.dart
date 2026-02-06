import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visitor_practise/core/constants/app_routes.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

class AdminPasswordDialog extends StatefulWidget {
  const AdminPasswordDialog({super.key});

  @override
  State<AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<AdminPasswordDialog> {
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String? _errorText;
  String _expectedPassword = '1234';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminPassword();
  }

  Future<void> _loadAdminPassword() async {
    final pin = await SecureStorageService.getAdminPin();
    if (!mounted) return;
    setState(() {
      _expectedPassword = pin?? '1234';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _validate(){
    if (_loading) return;
    if (_passwordCtrl.text.trim() == _expectedPassword) {
       Navigator.of(context).pop(true); // Return true on success
    } else {
      setState(() => _errorText = 'Incorrect password');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth = AppBreakpoints.getContentWidth(width);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Center(
        child: Material(
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBodyWidth/1.5),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Admin Sign In', style: tt.titleLarge),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    Text(
                      'Enter the administrator password to exit kiosk mode. '
                      'You can change this password from the dashboard.',
                      style: tt.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: _errorText,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      onSubmitted: (_) => _validate(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _loading ? null : _validate,
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}