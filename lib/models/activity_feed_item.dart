import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/constants.dart';
import 'package:pondergram/pages/home.dart';
import 'package:pondergram/pages/post_screen.dart';
import 'package:pondergram/pages/profile.dart';
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
      username: doc.data()['username'],
      userId: doc.data()['userId'],
      type: doc.data()['type'],
      postId: doc.data()['postId'],
      userProfileImage: doc.data()['userProfileImg'],
      commentData: doc.data()['commentData'],
      mediaUrl: doc.data()['mediaUrl'],
      timestamp: doc.data()['timestamp'],
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
          userId: currentUser?.id,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 7.0,
              color: Theme.of(context).accentColor,
            )
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                  children: [
                    TextSpan(text: username, style: kBoldText),
                    TextSpan(text: ' $activityItemText')
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
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
