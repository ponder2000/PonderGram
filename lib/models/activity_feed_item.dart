import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/pages/home.dart';
import 'package:pondergram/pages/post_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeedItem extends StatelessWidget {
  final String username,
      userId,
      type,
      mediaUrl,
      postId,
      userProfileImage,
      commentData;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.commentData,
    this.mediaUrl,
    this.postId,
    this.timestamp,
    this.type,
    this.userId,
    this.userProfileImage,
    this.username,
  });

  Widget mediaPreview;
  String activityItemText;

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImage: doc['userProfileImg'],
      commentData: doc['commentData'],
      mediaUrl: doc['mediaUrl'],
      timestamp: doc['timestamp'],
    );
  }

  configureMediaPreview(BuildContext context) {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 60.0,
          width: 60.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(mediaUrl),
                    fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      );

      if (type == 'like')
        activityItemText = 'liked your post';
      else
        activityItemText = 'commented: $commentData';
    } else {
      activityItemText = 'started following you';
      mediaPreview = Text('');
    }
  }

  // show a full screen post
  showPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => print("--> Show user"),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                  children: [
                    TextSpan(
                        text: username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    TextSpan(text: ' $activityItemText')
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImage),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
