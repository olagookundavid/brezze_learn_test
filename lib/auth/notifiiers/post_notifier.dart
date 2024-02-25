import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class PostViewModel with ChangeNotifier {
  bool _loading = false;
  bool _delLoading = false;
  String? _error;

  bool get loading => _loading;
  bool get delLoading => _delLoading;
  String? get error => _error;
  final fireStore = FirebaseFirestore.instance;

  Future<void> uploadPostImageToFirebaseStorage(
      File image, String email, String post) async {
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
      await fireStore.collection('user_posts').add({
        'UserEmail': email,
        'Message': post,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
        'image': imageUrl
      });
    } catch (e) {
      _error = 'Error uploading image: $e';
      debugPrint(_error);
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> uploadPost(String email, String post) async {
    _loading = true;
    notifyListeners();
    try {
      await fireStore.collection('user_posts').add({
        'UserEmail': email,
        'Message': post,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
        'image': ''
      });
    } catch (e) {
      _error = 'Error uploading image: $e';
      debugPrint(_error);
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> likePost(String email, String postId) async {
    notifyListeners();
    try {
      await fireStore.collection('user_posts').doc(postId).update({
        "Likes": FieldValue.arrayUnion([email]) // arrayUnion = "add to array"
      });
    } catch (e) {
      _error = 'Error uploading image: $e';
      debugPrint(_error);
    }
    notifyListeners();
  }

  Future<void> unLikePost(String email, String postId) async {
    notifyListeners();
    try {
      await fireStore.collection('user_posts').doc(postId).update({
        "Likes":
            FieldValue.arrayRemove([email]) // arrayRemove = "remove to array"
      });
    } catch (e) {
      _error = 'Error uploading image: $e';
      debugPrint(_error);
    }
    notifyListeners();
  }

  Future<void> deletePost(String id) async {
    _delLoading = true;
    notifyListeners();
    try {
      final commentDocs = await fireStore
          .collection('user_posts')
          .doc(id)
          .collection('comments')
          .get();

      // delete the comments
      for (var doc in commentDocs.docs) {
        await FirebaseFirestore.instance
            .collection('user_posts')
            .doc(id)
            .collection('comments')
            .doc(doc.id)
            .delete();
      }

      // then delete the post
      await fireStore.collection('user_posts').doc(id).delete();
    } catch (e) {
      _error = 'Error uploading image: $e';
      debugPrint(_error);
    }
    _delLoading = false;
    notifyListeners();
  }

  Future<void> addComment(String email, String postId, String msg) async {
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('user_posts')
          .doc(postId)
          .collection('comments')
          .add({
        'CommentText': msg,
        'CommentedBy': email,
        'CommentTime': Timestamp.now()
      });
    } catch (e) {
      _error = 'Error uploading image: $e';
      debugPrint(_error);
    }
    notifyListeners();
  }

  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return FirebaseFirestore.instance
        .collection('user_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('CommentTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPostsStream() {
    return FirebaseFirestore.instance
        .collection('user_posts')
        .orderBy('TimeStamp', descending: false)
        .snapshots();
  }
}
