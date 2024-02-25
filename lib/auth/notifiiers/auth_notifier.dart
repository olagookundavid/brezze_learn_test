import 'package:brezze_learn_test/helper/storage_class.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// class AuthenticationNotifier extends ChangeNotifier {
//   void logout() {
//     FirebaseAuth.instance.signOut();
//   }
// }

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel() {
    // Initialize the user state
    _initUser();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize user state from Firebase Auth
  Future<void> _initUser() async {
    _user = _auth.currentUser;
    notifyListeners();
  }

  // Sign in with email and password
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      //Store credentials in local storage
      await HiveStorage.put(HiveKeys.userName, email);
      await HiveStorage.put(HiveKeys.password, password);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error signing in: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error signing out: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailPassword(
      String email, String password, String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // after creating the user, create new collection called "users"
      FirebaseFirestore.instance
          // create the collection
          .collection('users')
          // create doc for userCredential
          .doc(userCredential.user!.email)
          // set 'username' -> text before @ sign in email
          .set({
        'username': name,
        'bio': 'Enter your bio here...',
        'avatar': ''
      });
      _user = userCredential.user;
      //Store credentials in local storage
      await HiveStorage.put(HiveKeys.userName, email);
      await HiveStorage.put(HiveKeys.password, password);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error signing in: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Set loading state to true
      _isLoading = true;
      notifyListeners();

      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Reset error message if successful
      _errorMessage = null;
    } catch (e) {
      // Set error message if there's an error
      _errorMessage = e.toString();
    } finally {
      // Set loading state to false regardless of success or failure
      _isLoading = false;
      notifyListeners();
    }
  }

  getUser() {
    var data = _auth.authStateChanges();
    return data;
  }
}
