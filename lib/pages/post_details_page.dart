// ignore_for_file: use_build_context_synchronously

import 'package:brezze_learn_test/auth/notifiiers/auth_notifier.dart';
import 'package:brezze_learn_test/auth/notifiiers/post_notifier.dart';
import 'package:brezze_learn_test/components/comment.dart';
import 'package:brezze_learn_test/components/delete_button.dart';
import 'package:brezze_learn_test/helper/alert_box.dart';
import 'package:brezze_learn_test/helper/helper_methods.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:brezze_learn_test/widgets/buttons/comment_button.dart';
import 'package:brezze_learn_test/widgets/buttons/like_button.dart';
import 'package:brezze_learn_test/widgets/cache_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({super.key, required this.post});
  final QueryDocumentSnapshot<Map<String, dynamic>> post;

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
// Like Button - isLiked
  bool isLiked = false;

// Comment Text Controller
  final _commentTextController = TextEditingController();

// Init State
  @override
  void initState() {
    super.initState();
    // if our current user's email is contained in the list of likes, isLiked = true
    isLiked = List<String>.from(widget.post['Likes'] ?? [])
        .contains(FirebaseAuth.instance.currentUser!.email);
  }

// Add a Comment to Firestore -> create 'comments' collection

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthViewModel>(context).user;
    final postsViewModel = Provider.of<PostViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).cardColor,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Post Details',
          style: GoogleFonts.rammettoOne(
              color: Theme.of(context).primaryColorLight, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
        child: Column(
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
                    if (widget.post['UserEmail'] == currentUser?.email)
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              // content
                              content: const Text(
                                'Are you sure you want to delete this post?',
                                textAlign: TextAlign.center,
                              ),
                              // buttons
                              actions: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 15.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      10.pw,

                                      // delete button
                                      Consumer<PostViewModel>(
                                          builder: (context, post, child) {
                                        return post.delLoading
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton(
                                                onPressed: () async {
                                                  await post.deletePost(
                                                      widget.post.id);
                                                  if (post.error != null) {
                                                    if (mounted) {
                                                      getAlert(
                                                          context, post.error!);
                                                    }
                                                    return;
                                                  }
                                                  if (mounted) {
                                                    getAlert(context,
                                                        'Successfully deleted all posts');
                                                  }

                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              );
                                      }),
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

            SizedBox(height: 15.h),
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
                        child: CachedImageHelper(url: widget.post['image'])),
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
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.sp),
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
                Consumer<PostViewModel>(builder: (context, post, child) {
                  return LikeButton(
                    isLiked: isLiked,
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                      });

                      if (isLiked) {
                        // if the post is now liked, add the user's email to the "Likes" field (in the postMessage method)
                        post.likePost(currentUser!.email!, widget.post.id);
                      } else {
                        // if the post is now unliked, remove the user's email form the "Likes" field
                        post.unLikePost(currentUser!.email!, widget.post.id);
                      }
                    },
                  );
                }),
                10.pw,

                // add number of likes
                Text(List<String>.from(widget.post['Likes'] ?? [])
                    .length
                    .toString()),
                10.pw,

                // comment button
                CommentButton(onTap: () {
                  showCommentDialog(widget.post.id);
                }),
                10.pw,

                // add number of comments
              ],
            ),

            10.ph,

            // Show Comments Under Post
            StreamBuilder<QuerySnapshot>(
              // listening for -> comments inside of user posts -> display in descending order based on comment time
              stream: postsViewModel.getCommentsStream(widget.post.id),
              builder: ((context, snapshot) {
                // show loading circle if no data
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor),
                  );
                }

                return ListView(
                  shrinkWrap: true, // for nested lists
                  physics: const NeverScrollableScrollPhysics(),
                  // grab snapshot data and return comments
                  children: snapshot.data!.docs.map((doc) {
                    // get comment from Firebase
                    final commentData = doc.data() as Map<String, dynamic>;

                    // return the comment
                    return Comment(
                        text: commentData['CommentText'],
                        user: commentData['CommentedBy'],
                        time: formatDate(commentData['CommentTime']));
                  }).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void showCommentDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        title: const Text('Add Comment',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400.w,
          child: TextFormField(
            controller: _commentTextController,
            decoration: const InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Write a comment...',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // cancel button
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () {
                    // pop dialog box
                    Navigator.pop(context);
                    // clear controller
                    _commentTextController.clear();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ),

                10.pw,

                // post comment button
                Consumer<PostViewModel>(builder: (context, postComment, child) {
                  final currentUser = Provider.of<AuthViewModel>(context).user;
                  return ElevatedButton(
                    onPressed: () async {
                      if (_commentTextController.text.isEmpty) {
                        if (mounted) {
                          getAlert(context, 'Please pass in a message');
                        }

                        return;
                      }
                      // add comment on button press
                      await postComment.addComment(
                          currentUser!.email!, id, _commentTextController.text);
                      if (postComment.error != null) {
                        if (mounted) {
                          getAlert(context, postComment.error!);
                        }
                        return;
                      }
                      if (mounted) {
                        getAlert(context, 'Succesfully added a comment');
                      }
                      // pop dialog box
                      Navigator.pop(context);
                      // clear controller
                      _commentTextController.clear();
                    },
                    child: const Text('Post Comment',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
