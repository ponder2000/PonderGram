import 'package:flutter/material.dart';
import 'package:pondergram/models/comments.dart';
import 'package:pondergram/widgets/loading.dart';
import 'package:pondergram/widgets/reusable_header.dart';
import 'package:pondergram/pages/home.dart';

class Comments extends StatefulWidget {
  final String postId, postOwnerId, postMediaUrl;
  Comments({this.postId, this.postMediaUrl, this.postOwnerId});

  @override
  _CommentsState createState() => _CommentsState(
        postId: postId,
        postMediaUrl: postMediaUrl,
        postOwnerId: postOwnerId,
      );
}

class _CommentsState extends State<Comments> {
  final String postId, postOwnerId, postMediaUrl;
  _CommentsState({this.postId, this.postMediaUrl, this.postOwnerId});

  TextEditingController commentController = TextEditingController();
  bool canPost = false;

  addCommentToActivityFeed() {
    bool _isPostOwner = currentUser.id == postOwnerId;
    if (_isPostOwner) return;
    activityFeedRef.doc(postOwnerId).collection('feedItems').add({
      'type': 'comment',
      'commentData': commentController.text.trim(),
      'timestamp': DateTime.now(),
      'postId': widget.postId,
      'userId': currentUser.id,
      'username': currentUser.username,
      'userProfileImg': currentUser.photoUrl,
      'mediaUrl': postMediaUrl,
    });
  }

  addComment() {
    if (commentController.text.trim().isEmpty) return;
    commentsRef.doc(postId).collection('postComment').add({
      'username': currentUser.username,
      'comment': commentController.text,
      'timestamp': DateTime.now(),
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id,
    });
    addCommentToActivityFeed();
    commentController.clear();
  }

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .doc(postId)
          .collection('postComment')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress();
        List<Comment> comments = [];
        snapshot.data.docs.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: header(context, isAppTitle: false, title: "Comments"),
        body: Column(
          children: [
            Expanded(child: buildComments()),
            Divider(),
            ListTile(
              tileColor: Colors.white,
              title: TextFormField(
                onChanged: (val) {
                  setState(() {
                    canPost = val.trim().isEmpty;
                  });
                },
                controller: commentController,
                decoration: InputDecoration(
                  labelText: "write a comment",
                ),
              ),
              trailing: OutlineButton(
                onPressed: canPost ? () {} : () => addComment(),
                borderSide: BorderSide.none,
                child: Text("Post"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
