import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthenticationNotifier extends ChangeNotifier {
  void logout() {
    FirebaseAuth.instance.signOut();
  }
}
