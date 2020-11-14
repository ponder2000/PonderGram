import 'package:flutter/material.dart';
import 'package:pondergram/pages/post.dart';
import 'package:pondergram/pages/post_screen.dart';
import 'package:pondergram/widgets/custom_image.dart';

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
    return GestureDetector(
      onTap: () => showPost(context),
      child: customCachedNetworkImage(post.mediaUrl),
    );
  }
}
