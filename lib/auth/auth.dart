import 'package:brezze_learn_test/auth/login_or_register.dart';
import 'package:brezze_learn_test/auth/notifiiers/auth_notifier.dart';
import 'package:brezze_learn_test/pages/landing_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        User? user = authViewModel.user;

        // Return different widgets based on the user's authentication status
        if (user != null) {
          return const LandingPage();
        } else {
          return const LoginOrRegister();
        }
      },
    );
  }
}



//     StreamBuilder(
//         // listens for changes in auth state
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
// // If user IS logged in
//           if (snapshot.hasData) {
//             return const LandingPage();
//           }
// // If user is NOT logged in
//           else {
//             return const LoginOrRegister();
//           }
//         },
//       ),