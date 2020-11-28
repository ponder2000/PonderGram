import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/pages/post.dart';
import 'package:pondergram/pages/post_screen.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile({this.post});

  showPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 10.0)],
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20.0),
              image: DecorationImage(
                image: CachedNetworkImageProvider(post.mediaUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
