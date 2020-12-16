import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/constants.dart';
import 'package:pondergram/models/user.dart';
import 'package:pondergram/pages/home.dart';
import 'package:pondergram/pages/profile.dart';
import 'package:pondergram/widgets/custom_image.dart';
import 'package:pondergram/widgets/loading.dart';

import 'comments.dart';

class Post extends StatefulWidget {
  final String postId, ownerId, username, location, caption, mediaUrl;
  final dynamic likes;
  Timestamp timestamp;

  Post(
      {this.postId,
      this.caption,
      this.likes,
      this.location,
      this.mediaUrl,
      this.ownerId,
      this.username,
      this.timestamp});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc.data()["postId"],
      caption: doc.data()['caption'],
      likes: doc.data()['likes'],
      location: doc.data()['location'],
      mediaUrl: doc.data()['mediaUrl'],
      ownerId: doc.data()['ownerId'],
      username: doc.data()['username'],
      timestamp: doc.data()['timestamp'],
    );
  }

  @override
  _PostState createState() => _PostState(
        caption: this.caption,
        likes: this.likes,
        location: this.location,
        mediaUrl: this.mediaUrl,
        ownerId: this.ownerId,
        postId: this.postId,
        username: this.username,
      );
}

class _PostState extends State<Post> {
  final String postId, ownerId, username, location, caption, mediaUrl;
  Map likes;
  int likeCount = 0;
  final String currentUserId = currentUser?.id;
  bool isLike = false;
  bool showHeart = false;

  _PostState(
      {this.postId,
      this.caption,
      this.likes,
      this.location,
      this.mediaUrl,
      this.ownerId,
      this.username});

  @override
  void initState() {
    super.initState();
    setState(() {
      // print('---> ${likes[currentUserId]}');
      if (likes[currentUserId] == null)
        isLike = false;
      else if (likes[currentUserId])
        isLike = true;
      else
        isLike = false;
      likeCount = getLikeCount(likes);
    });
  }

  int getLikeCount(Map likes) {
    int _count = 0;
    if (likes == null) return _count;
    likes.values.forEach((val) {
      if (val) _count++;
    });
    return _count;
  }

  // will add likes to activity feed
  addLikeToActivityFeed() {
    // if liked by postOwner user then do nothing
    bool _isPostOwner = currentUserId == ownerId;
    if (_isPostOwner) return;
    activityFeedRef.doc(ownerId).collection('feedItems').doc(postId).set({
      'type': 'like',
      'username': currentUser.username,
      'userId': currentUser.id,
      'postId': postId,
      'userProfileImg': currentUser.photoUrl,
      'mediaUrl': mediaUrl,
      'timestamp': DateTime.now(),
    });
  }

  // will remove if they dislike from activity feed
  removeLikeToActivityFeed() {
    bool _isPostOwner = currentUserId == ownerId;
    if (_isPostOwner) return;
    activityFeedRef
        .doc(ownerId)
        .collection('feedItems')
        .doc(postId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  hdnleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      // if users has previously liked the post and now unliking it
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});

      removeLikeToActivityFeed();
      setState(() {
        likeCount--;
        isLike = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});

      addLikeToActivityFeed();
      setState(() {
        likeCount++;
        isLike = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  //show a full profile page
  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          profileId: profileId,
        ),
      ),
    );
  }

  deletePost() async {
    // post data delete
    postsRef.doc(ownerId).collection('userPosts').doc(postId).get().then((d) {
      if (d.exists) {
        d.reference.delete();
      }
    });

    // post storage delete
    storageRef.child("post_$postId.jpg").delete();

    // activity feed delete
    QuerySnapshot activitySnapshot = await activityFeedRef
        .doc(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .get();

    activitySnapshot.docs.forEach((element) {
      if (element.exists) element.reference.delete();
    });

    // comment delete
    QuerySnapshot commentSnapshot =
        await commentsRef.doc(postId).collection('comments').get();

    commentSnapshot.docs.forEach((element) {
      if (element.exists) element.reference.delete();
    });
  }

  handleDeltePost(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Delete post?"),
          children: [
            SimpleDialogOption(
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                deletePost();
              },
            ),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  buildPostHeader() {
    return FutureBuilder(
        future: usersRef.doc(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return circularProgress();
          User user = User.fromDocument(snapshot.data);
          bool isPostOwner = currentUserId == ownerId;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            title: GestureDetector(
              child: Text(
                user.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => showProfile(context, profileId: user.id),
            ),
            subtitle: Text(location, style: kBoldText),
            trailing: isPostOwner
                ? IconButton(
                    onPressed: () => handleDeltePost(context),
                    icon: Icon(Icons.more_vert),
                  )
                : Text(''),
          );
        });
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => hdnleLikePost(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          customCachedNetworkImage(mediaUrl),
          // double tap visual feature
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 500),
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.bounceOut,
                  cycles: 0,
                  builder: (context, anim, child) => Transform.scale(
                    scale: anim.value,
                    child: Icon(
                      Icons.favorite,
                      size: 80.0,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                )
              : Text(''),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () => hdnleLikePost(),
              child: Icon(
                isLike ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.red,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 40.0, right: 20.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                mediaUrl: mediaUrl,
                postId: postId,
                ownerId: ownerId,
              ),
              child: Icon(
                Icons.comment,
                size: 28.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 10.0),
              child: Text(
                "$username",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(caption),
            ),
          ],
        ),
        Container(height: 5.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 10.0)],
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          children: [
            buildPostHeader(),
            buildPostImage(),
            buildPostFooter(),
          ],
        ),
      ),
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postMediaUrl: mediaUrl,
      postOwnerId: ownerId,
    );
  }));
}
