import 'dart:io';

import 'package:brezze_learn_test/auth/notifiiers/auth_notifier.dart';
import 'package:brezze_learn_test/auth/notifiiers/post_notifier.dart';
import 'package:brezze_learn_test/helper/alert_box.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:brezze_learn_test/pages/auth/log_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// Text Controller
  TextEditingController postController = TextEditingController();
  late final ScrollController ctrl;
  File? postImage;
  @override
  void initState() {
    ctrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(MediaQuery.of(context).viewInsets.bottom.toString());
    final currentUser = Provider.of<AuthViewModel>(context).user;
    final postsViewModel = Provider.of<PostViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'ChatBox',
          style: GoogleFonts.rammettoOne(
              color: Theme.of(context).primaryColorLight, fontSize: 24.sp),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10.r),
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
              'Logged in as ${currentUser?.email!}',
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 30.h),
                            child: Text(
                                'Nothing to see yet, start sending messages to see chats',
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.zcoolKuaiLe(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 24.sp)),
                          ),
                        )
                      : ListView.builder(
                          controller: ctrl,
                          reverse: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            // get the message
                            final post = snapshot.data!.docs[index];
                            // post message (message + user email)
                            return Post(
                              post: post,
                            );
                          }),
                        );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
              stream: postsViewModel.getPostsStream(),
            ),
          ),
          // Post Text Field
          Padding(
            padding: EdgeInsets.all(20.h),
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
                    Consumer<PostViewModel>(builder: (context, post, child) {
                      return post.loading
                          ? const CircularProgressIndicator()
                          : IconButton(
                              onPressed: () async {
                                if (postController.text.isEmpty) {
                                  if (mounted) {
                                    getAlert(
                                        context, 'Please pass in a message');
                                  }
                                  return;
                                }
                                if (postImage == null) {
                                  await post.uploadPost(
                                      currentUser!.email!, postController.text);
                                  if (post.error != null) {
                                    if (mounted) {
                                      getAlert(context, post.error!);
                                    }
                                    return;
                                  }
                                  ctrl.animateTo(
                                    ctrl.position.maxScrollExtent,
                                    curve: Curves.easeOut,
                                    duration: const Duration(milliseconds: 500),
                                  );
                                  if (mounted) {
                                    getAlert(
                                        context, 'Succesfully added a post');
                                  }
                                  postController.clear();
                                  return;
                                }
                                await post.uploadPostImageToFirebaseStorage(
                                    postImage!,
                                    currentUser!.email!,
                                    postController.text);
                                if (post.error != null) {
                                  if (mounted) {
                                    getAlert(context, post.error!);
                                  }
                                  return;
                                }
                                ctrl.animateTo(
                                  ctrl.position.maxScrollExtent,
                                  curve: Curves.easeOut,
                                  duration: const Duration(milliseconds: 500),
                                );
                                if (mounted) {
                                  getAlert(context, 'Succesfully added a post');
                                }
                                postController.clear();
                                postImage = null;
                              },
                              icon: Icon(Icons.arrow_circle_right,
                                  color: Theme.of(context).primaryColor,
                                  size: 34.r));
                    })
                  ],
                ),
                if (MediaQuery.of(context).viewInsets.bottom < 200.h)
                  SizedBox(height: 80.h)
                // Consumer<ScreenHeight>(builder: (context, res, child) {
                //   return SizedBox(height: res.isOpen ? 1 : 80.h);
                // })
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
                child: Icon(
                  Icons.camera_alt,
                  size: 40.h,
                ),
              ),
              30.pw,
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
                child: Icon(
                  Icons.photo_library_rounded,
                  size: 40.r,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


    // print(MediaQuery.of(Scaffold.of(context).context).viewInsets.bottom);
    // print(EdgeInsets.fromViewPadding(
    //         View.of(context).viewInsets, View.of(context).devicePixelRatio)
    //     .bottom);