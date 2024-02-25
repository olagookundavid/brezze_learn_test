import 'dart:io';
import 'package:brezze_learn_test/auth/notifiiers/auth_notifier.dart';
import 'package:brezze_learn_test/auth/notifiiers/profile_notifier.dart';
import 'package:brezze_learn_test/helper/alert_box.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:brezze_learn_test/widgets/cache_image.dart';
import 'package:brezze_learn_test/widgets/profile_text_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
// Edit Field
  Future<void> editField(String field) async {
    // create empty string value
    String newValue = "";
    newValue = await showDialog(
      context: context,
      // dialog box when edit button is clicked
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        title: Text(
          'Edit $field',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400.w,
          child: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple)),
              hintText: 'Enter new $field',
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            // assign new value to the value of 'username'
            onChanged: (value) {
              newValue = value;
            },
          ),
        ),
        // Buttons
        actions: [
          // cancel button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // save button
              Padding(
                padding: EdgeInsets.only(bottom: 15.w),
                child: Consumer<ProfileViewModel>(
                    builder: (context, profile, child) {
                  return profile.loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (newValue.isNotEmpty) {
                              // current user from usersCollection -> update field with new value
                              await profile.updateProfile(
                                  Provider.of<AuthViewModel>(context,
                                          listen: false)
                                      .user!
                                      .email!,
                                  field,
                                  newValue);
                            }
                            if (mounted) {
                              Navigator.of(context).pop(newValue);
                            }
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                }),
              ),
            ],
          ),
        ],
      ),
    );

    // update new username to Firestore ONLY if edit field has data
  }

  // Image Picker
  imagePickDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
              child: Text('Upload Image',
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
                    profileImage = File(image.path);
                    setState(() {});
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Icon(
                  Icons.camera_alt,
                  size: 40.r,
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
                    profileImage = File(image.path);
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

// Profile Pic File Image
  File? profileImage;

// Init State
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthViewModel>(context).user;

    final profileViewModel = Provider.of<ProfileViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Profile',
          style: GoogleFonts.rammettoOne(
              color: Theme.of(context).primaryColorLight, fontSize: 24),
        ),
      ),

// Body
      body: StreamBuilder<DocumentSnapshot>(
        // stream -> listening for collection of 'users'
        stream: profileViewModel.getProfileStream(currentUser!.email!),
        builder: (context, snapshot) {
          // get user data
          if (snapshot.hasData) {
            // store found data in 'userData' variable
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            // display as ListView
            return ListView(
              children: [
                10.ph,
                // profile pic
                InkWell(
                  onTap: () {
                    imagePickDialog();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 55.w),
                    child: SizedBox(
                      height: 250.h,
                      child: ClipOval(
                        child: profileImage == null
                            ? CachedImageHelper(url: userData['avatar'])
                            : ClipOval(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: FileImage(
                                          profileImage!,
                                        ),
                                        fit: BoxFit.fill),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                20.ph,

                // User Email
                Text(
                  currentUser.email!,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

// User Details
                Padding(
                  padding: EdgeInsets.only(left: 25.w, top: 20.h),
                  child: Text('My Details',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold)),
                ),

                // Username
                ProfileTextBox(
                  // display stored data from userData variable ('username)
                  text: userData['username'],
                  sectionName: 'Username',
                  onPressed: () => editField('username'),
                ),

                // display stored data from userData variable ('bio')
                ProfileTextBox(
                  // display  ('bio')
                  text: userData['bio'],
                  sectionName: 'Bio',
                  onPressed: () => editField('bio'),
                ),

                40.ph,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<ProfileViewModel>(
                        builder: (context, profile, child) {
                      return profile.loading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                // Save image to firebase storage
                                if (profileImage == null) {
                                  return;
                                }
                                await profile
                                    .uploadProfileImageToFirebaseStorage(
                                        profileImage!, currentUser.email!);
                                if (profile.error != null) {
                                  // Show a snackbar with the error message
                                  if (mounted) {
                                    getAlert(context, profile.error!);
                                  }
                                  return;
                                }
                                if (mounted) {
                                  getAlert(context,
                                      'Successfully updated profile picture!');
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).primaryColorLight),
                                ),
                              ));
                    }),
                  ],
                ),
                30.ph
              ],
            );
            // error handlers
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }

          return Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor));
        },
      ),
    );
  }
}
