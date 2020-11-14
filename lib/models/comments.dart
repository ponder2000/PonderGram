import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comment extends StatelessWidget {
  final String username, userId, avatarUrl, comment;
  final Timestamp timestamp;

  Comment(
      {this.avatarUrl,
      this.comment,
      this.timestamp,
      this.userId,
      this.username});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      username: doc['username'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
