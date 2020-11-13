import 'package:flutter/material.dart';
import 'package:pondergram/pages/post.dart';
import 'package:pondergram/widgets/custom_image.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile({this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("---> showing post"),
      child: customCachedNetworkImage(post.mediaUrl),
    );
  }
}
