import 'dart:io';

import 'package:brezze_learn_test/controller/auth_controller.dart';
import 'package:brezze_learn_test/pages/auth/log_out.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// Current User
  final currentUser = FirebaseAuth.instance.currentUser!;
  AuthController? authController;
// Text Controller
  TextEditingController postController = TextEditingController();

// Post Message Method
  void postMessage(String image) {
    // only post if there is something in the textfield
    if (postController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('user_posts').add({
        'UserEmail': currentUser.email,
        'Message': postController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
        'image': image
      });
    }
    postController.clear();
  }

// Sign User Out

  double keyBoardHeight = 0;
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addObserver(keyboard);
  // }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(keyboard);
  //   super.dispose();
  // }

  // @override
  // void keyboard() {
  //   final double newKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  //   setState(() {
  //     keyBoardHeight = newKeyboardHeight;
  //   });
  // }
  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
  }

  File? postImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'ChatBox',
          style: GoogleFonts.rammettoOne(
              color: Theme.of(context).primaryColorLight, fontSize: 24),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  context: context,
                  builder: (context) => Logout(),
                );
              },
              child: Icon(
                Icons.logout_rounded,
                size: 25.r,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Center(
                child: Text(
              'Logged in as ${currentUser.email!}',
              style: TextStyle(color: Colors.grey, fontSize: 15.sp),
            )),
          ),
          Expanded(
            child: StreamBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.docs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Text(
                                'Nothing to see yet, start sending messages to see chats',
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.zcoolKuaiLe(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 24.sp)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            // get the message
                            final post = snapshot.data!.docs[index];
                            // post message (message + user email)
                            return Post(
                              post: post,
                              // message: post['Message'],
                              // user: post['UserEmail'],
                              // postId: post.id,
                              // likes: List<String>.from(post['Likes'] ?? []),
                            );
                          }),
                        );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
              stream: FirebaseFirestore.instance
                  .collection('user_posts')
                  .orderBy('TimeStamp', descending: false)
                  .snapshots(),
            ),
          ),
// Post Text Field
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          controller: postController,
                          decoration: InputDecoration(
                              suffixIcon: InkWell(
                                  onTap: () {
                                    imagePickDialog();
                                  },
                                  child: const Icon(Icons.attach_file_rounded)),
                              hintText: 'What\'s on your mind?',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor))),
                        ),
                      ),
                    ),

                    // Post Button
                    IconButton(
                        onPressed: () async {
                          if (postImage == null) {
                            postMessage('');
                            return;
                          }
                          String imageUrl = await authController!
                              .uploadImageToFirebaseStorage(postImage!);
                          postImage = null;
                          postMessage(imageUrl);
                        },
                        icon: Icon(Icons.arrow_circle_right,
                            color: Theme.of(context).primaryColor, size: 34.r))
                  ],
                ),
                if (MediaQuery.of(context).viewInsets.bottom < 10)
                  const SizedBox(height: 100)
              ],
            ),
          ),

          // Logged in user
        ],
      ),
    );
  }

  // Image Picker
  imagePickDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
              child: Text('Attach Image',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor))),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  final ImagePicker picker0 = ImagePicker();
                  final XFile? image =
                      await picker0.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    postImage = File(image.path);
                    setState(() {});
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Icon(
                  Icons.camera_alt,
                  size: 40,
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              InkWell(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    postImage = File(image.path);
                    setState(() {});
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Icon(
                  Icons.photo_library_rounded,
                  size: 40,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
