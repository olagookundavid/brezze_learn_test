import 'package:brezze_learn_test/auth/notifiiers/auth_notifier.dart';
import 'package:brezze_learn_test/auth/notifiiers/post_notifier.dart';
import 'package:brezze_learn_test/components/delete_button.dart';
import 'package:brezze_learn_test/helper/alert_box.dart';
import 'package:brezze_learn_test/helper/helper_methods.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:brezze_learn_test/pages/post_details_page.dart';
import 'package:brezze_learn_test/widgets/buttons/comment_button.dart';
import 'package:brezze_learn_test/widgets/buttons/like_button.dart';
import 'package:brezze_learn_test/widgets/cache_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Post extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> post;

  const Post({super.key, required this.post});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
// Like Button - isLiked
  bool isLiked = false;
  int? totComment;

// Init State
  @override
  void initState() {
    super.initState();
    isLiked = List<String>.from(widget.post['Likes'] ?? [])
        .contains(FirebaseAuth.instance.currentUser!.email);
  }

// Add a Comment to Firestore -> create 'comments' collection

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthViewModel>(context).user;
    final postsViewModel = Provider.of<PostViewModel>(context);
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
          borderRadius: BorderRadius.circular(15.r),
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
                          (widget.post['UserEmail'] == currentUser?.email)
                              ? 'You'
                              : widget.post['UserEmail'],
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w700),
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
                                      padding: EdgeInsets.only(bottom: 15.h),
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
                                                          getAlert(context,
                                                              post.error!);
                                                        }
                                                        return;
                                                      }
                                                      if (mounted) {
                                                        getAlert(context,
                                                            'Successfully deleted all posts');
                                                      }
                                                      // ignore: use_build_context_synchronously
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
                          child: CachedImageHelper(url: widget.post['image']),
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
                            post.unLikePost(
                                currentUser!.email!, widget.post.id);
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
                    CommentButton(onTap: () {}),
                    10.pw,

                    // add number of comments
                    StreamBuilder<QuerySnapshot>(
                      stream: postsViewModel.getCommentsStream(widget.post.id),
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
