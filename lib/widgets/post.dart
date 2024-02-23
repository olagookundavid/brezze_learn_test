import 'package:brezze_learn_test/components/delete_button.dart';
import 'package:brezze_learn_test/helper/helper_methods.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:brezze_learn_test/pages/post_details_page.dart';
import 'package:brezze_learn_test/widgets/buttons/comment_button.dart';
import 'package:brezze_learn_test/widgets/buttons/like_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Post extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> post;

  const Post({super.key, required this.post});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
// Get user from Firebase
  final currentUser = FirebaseAuth.instance.currentUser!;

// Like Button - isLiked
  bool isLiked = false;
  int? totComment;

// Init State
  @override
  void initState() {
    super.initState();
    isLiked = List<String>.from(widget.post['Likes'] ?? [])
        .contains(currentUser.email);
  }

// Toggle 'like' button
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

// If User "Likes" Post -> Add it to Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('user_posts').doc(widget.post.id);

    if (isLiked) {
      // if the post is now liked, add the user's email to the "Likes" field (in the postMessage method)
      postRef.update({
        "Likes": FieldValue.arrayUnion(
            [currentUser.email]) // arrayUnion = "add to array"
      });
    } else {
      // if the post is now unliked, remove the user's email form the "Likes" field
      postRef.update({
        "Likes": FieldValue.arrayRemove(
            [currentUser.email]) // arrayRemove = "removes from array"
      });
    }
  }

// Add a Comment to Firestore -> create 'comments' collection

  @override
  Widget build(BuildContext context) {
// Post Tile
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return PostDetail(
            post: widget.post,
          );
        },
      )),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        margin: EdgeInsets.only(top: 15.h, left: 15.w, right: 15.w),
        padding: EdgeInsets.all(15.r),
        child: Column(
          children: [
            Column(
              children: [
                // Profile pic, user, delete button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // profile pic
                    Text(formatDate(widget.post['TimeStamp'])),
                    // user who posted

                    Row(
                      children: [
                        Text(
                          widget.post['UserEmail'],
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600),
                        ),
                        // Delete Post
                        if (widget.post['UserEmail'] == currentUser.email)
                          DeleteButton(
                            onTap: () {
                              // Delete post confirmation dialog box
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.grey.shade200,
                                  // header
                                  title: const Text(
                                    'Delete Post',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  // content
                                  content: const Text(
                                    'Are you sure you want to delete this post?',
                                    textAlign: TextAlign.center,
                                  ),
                                  // buttons
                                  actions: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // cancel button
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.deepPurple),
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          // delete button
                                          ElevatedButton(
                                            onPressed: () async {
                                              // delete the comments from firestore first
                                              // if you only delete the post, the comments will still remain

                                              // create variable called commentDocs
                                              final commentDocs =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('user_posts')
                                                      .doc(widget.post.id)
                                                      .collection('comments')
                                                      .get();

                                              // delete the comments
                                              for (var doc
                                                  in commentDocs.docs) {
                                                await FirebaseFirestore.instance
                                                    .collection('user_posts')
                                                    .doc(widget.post.id)
                                                    .collection('comments')
                                                    .doc(doc.id)
                                                    .delete()
                                                    .then((value) => print(
                                                        'comments deleted'))
                                                    .catchError((error) =>
                                                        'failed to delete comments: $error');
                                              }

                                              // then delete the post
                                              FirebaseFirestore.instance
                                                  .collection('user_posts')
                                                  .doc(widget.post.id)
                                                  .delete()
                                                  .then(
                                                    (value) =>
                                                        print('post deleted'),
                                                  )
                                                  .catchError(
                                                    (error) => print(
                                                        'failed to delete post: $error'),
                                                  );

                                              // dismiss the dialog
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),

                10.ph,
                if (widget.post['image'] != '')
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r)),
                        height: 200.h,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            widget.post['image'],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      3.ph,
                    ],
                  ),
                // Post Row
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // post message
                        SizedBox(
                          width: 300.w,
                          child: Text(
                            widget.post['Message'],
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // like and comment buttons
                Row(
                  children: [
                    LikeButton(
                      isLiked: isLiked,
                      onTap: toggleLike,
                    ),
                    10.pw,

                    // add number of likes
                    Text(List<String>.from(widget.post['Likes'] ?? [])
                        .length
                        .toString()),
                    10.pw,

                    // comment button
                    CommentButton(onTap: () {}),
                    10.pw,

                    // add number of comments
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('user_posts')
                          .doc(widget.post.id)
                          .collection('comments')
                          .orderBy('CommentTime', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          int commentsLength = snapshot.data!.docs.length;
                          return Text(commentsLength.toString());
                        } else if (snapshot.hasError) {
                          return const Text('0');
                        } else {
                          return const Text('0');
                        }
                      },
                    ),
                  ],
                ),

                10.ph,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
