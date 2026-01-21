import 'package:flutter/material.dart';
import 'package:visitor_practise/core/responsive/aap_breakpoints.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';

import 'package:visitor_practise/shared_widgets/auth_body.dart';


import 'package:visitor_practise/pages/auth/controller/auth_controller.dart';
import 'package:visitor_practise/pages/auth/widgets/tablet_auth_card.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final AuthController _authController; //controller callback the page: I finish the task, you UI should move to next

  @override void initState() {
    super.initState(); 
    //create the controller instance
    _authController = AuthController(
      onApproved: () async => _handleNavigation(),
    );

    // STEP 1: Immediately check if device is already authenticated.
    // if auth -> jump to dashboard -> dashboard checks if all information is stored in local
    _authController.bootstrap(
      onAlreadyAuthed: () async => _handleNavigation(),
    );
  }
  
  Future<void> _handleNavigation() async {
    final nav = Navigator.of(context);
    final messagerWindow = ScaffoldMessenger.of(context);

    try {
      final decision = await _authController.decideNextNavigation();
      
      if(!mounted) return;

      if (decision.routeName != null) {
        nav.pushReplacementNamed(decision.routeName!);
      }

    } catch (e) {
      if (!mounted) return;

      messagerWindow.showSnackBar(
        const SnackBar(
          content: Text(
            "Offline or Server Unreachable. Check Internet Connection and restart this app. If it's not internet issue, please contact developer.",
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }

  }


  @override
  void dispose() {
    // TODO: implement dispose
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxBodyWidth  = AppBreakpoints.getContentWidth(width);

    return Scaffold (
      body:Center(
        child: AnimatedBuilder (animation: _authController, builder: (context, _) {
          return SingleChildScrollView (
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBodyWidth),
              child: AuthBody(
                  siteTitle: 'Worx Kiosk - Visitor Management',
                  logoUrlTop: 'lib/assets/images/WorxSafety_Logo_NoShadow.png',
                  logoUrlBottom: 'lib/assets/images/Worx_PoweredBy_Logo_Mono.png',
                  menuContent: TabletAuthCard(controller: _authController)
              ),
            ),
          );
        }
        ),
      )
    );
  }
}