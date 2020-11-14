import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/models/user.dart';
import 'package:pondergram/pages/home.dart';
import 'package:pondergram/pages/timeline.dart';
import 'package:pondergram/widgets/custom_image.dart';
import 'package:pondergram/widgets/loading.dart';

import 'comments.dart';

class Post extends StatefulWidget {
  final String postId, ownerId, username, location, caption, mediaUrl;
  final dynamic likes;

  Post(
      {this.postId,
      this.caption,
      this.likes,
      this.location,
      this.mediaUrl,
      this.ownerId,
      this.username});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc["postId"],
      caption: doc['caption'],
      likes: doc['likes'],
      location: doc['location'],
      mediaUrl: doc['mediaUrl'],
      ownerId: doc['ownerId'],
      username: doc['username'],
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
  bool isLike;
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
      isLike = likes[currentUserId] == null ? false : true;
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

  hdnleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      // if users has previously liked the post and now unliking it
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
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

  buildPostHeader() {
    return FutureBuilder(
        future: userRef.doc(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return circularProgress();
          User user = User.fromDocument(snapshot.data);
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
              onTap: () => print("----> show profile"),
            ),
            subtitle: Text(location),
            trailing: IconButton(
                onPressed: () => print("---> deleting post"),
                icon: Icon(Icons.more_vert)),
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
                      color: Colors.white,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
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
