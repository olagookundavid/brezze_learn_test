import 'package:brezze_learn_test/components/comment.dart';
import 'package:brezze_learn_test/components/delete_button.dart';
import 'package:brezze_learn_test/helper/helper_methods.dart';
import 'package:brezze_learn_test/helper/utils.dart';
import 'package:brezze_learn_test/widgets/buttons/comment_button.dart';
import 'package:brezze_learn_test/widgets/buttons/like_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({super.key, required this.post});
  final QueryDocumentSnapshot<Map<String, dynamic>> post;

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final currentUser = FirebaseAuth.instance.currentUser!;

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
  void addComment(String commentText) {
    // adding collection called 'comments' to specific postId in 'user_posts' collection
    FirebaseFirestore.instance
        .collection('user_posts')
        .doc(widget.post.id)
        .collection('comments')
        .add({
      'CommentText': commentText,
      'CommentedBy': currentUser.email,
      'CommentTime': Timestamp.now()
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                  padding: const EdgeInsets.only(bottom: 15.0),
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
                                      const SizedBox(width: 10),

                                      // delete button
                                      ElevatedButton(
                                        onPressed: () async {
                                          // delete the comments from firestore first
                                          // if you only delete the post, the comments will still remain

                                          // create variable called commentDocs
                                          final commentDocs =
                                              await FirebaseFirestore.instance
                                                  .collection('user_posts')
                                                  .doc(widget.post.id)
                                                  .collection('comments')
                                                  .get();

                                          // delete the comments
                                          for (var doc in commentDocs.docs) {
                                            await FirebaseFirestore.instance
                                                .collection('user_posts')
                                                .doc(widget.post.id)
                                                .collection('comments')
                                                .doc(doc.id)
                                                .delete()
                                                .then((value) =>
                                                    print('comments deleted'))
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
                        maxLines: 10,
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
                CommentButton(onTap: showCommentDialog),
                10.pw,

                // add number of comments
              ],
            ),

            10.ph,

            // Show Comments Under Post
            StreamBuilder<QuerySnapshot>(
              // listening for -> comments inside of user posts -> display in descending order based on comment time
              stream: FirebaseFirestore.instance
                  .collection('user_posts')
                  .doc(widget.post.id)
                  .collection('comments')
                  .orderBy('CommentTime', descending: true)
                  .snapshots(),
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

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade200,
        title: const Text('Add Comment',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextFormField(
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
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

                const SizedBox(width: 10),

                // post comment button
                ElevatedButton(
                  onPressed: () {
                    // add comment on button press
                    addComment(_commentTextController.text);
                    // pop dialog box
                    Navigator.pop(context);
                    // clear controller
                    _commentTextController.clear();
                  },
                  child: const Text('Post Comment',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
