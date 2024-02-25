import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class ProfileViewModel with ChangeNotifier {
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;
  final fireStore = FirebaseFirestore.instance;

  Future<void> updateProfile(
      String email, String field, dynamic newValue) async {
    try {
      _loading = true;
      notifyListeners();

      await fireStore.collection('users').doc(email).update({field: newValue});

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = 'Failed to update profile: $e';
      notifyListeners();
    }
  }

  Future<void> uploadProfileImageToFirebaseStorage(
      File image, String email) async {
    _loading = true;
    notifyListeners();

    String? imageUrl;
    String fileName = path.basename(image.path);

    try {
      var reference =
          FirebaseStorage.instance.ref().child('profileImages/$fileName');
      UploadTask uploadTask = reference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      imageUrl = await taskSnapshot.ref.getDownloadURL();
      await fireStore
          .collection('users')
          .doc(email)
          .update({'avatar': imageUrl});
    } catch (e) {
      _error = 'Error uploading image: $e';
      debugPrint(_error);
    }

    _loading = false;
    notifyListeners();
  }

  Stream<DocumentSnapshot> getProfileStream(String email) {
    return fireStore
        .collection('users')
        // find doc of currentUser.email
        .doc(email)
        .snapshots();
  }
}
