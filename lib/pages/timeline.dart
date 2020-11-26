import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/pages/post.dart';
import 'package:pondergram/widgets/loading.dart';
import 'package:pondergram/widgets/reusable_header.dart';
import 'home.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> timelinePosts = [];
  bool isLoaded = false;
  @override
  void initState() {
    super.initState();
    getTimelinePosts();
  }

  getPosts(String userId) async {
    QuerySnapshot _posts =
        await postsRef.doc(userId).collection('userPosts').get();
    return _posts;
  }

  Future<List<String>> getFollowing() async {
    QuerySnapshot _followingSnap = await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();

    List<String> _following = [currentUser.id];
    _followingSnap.docs.forEach((d) {
      _following.add(d.id);
    });

    return _following;
  }

  getTimelinePosts() async {
    List<String> _following = await getFollowing();
    for (String userId in _following) {
      QuerySnapshot _postsSnap = await getPosts(userId);
      List<Post> _timelinePosts = [];
      _postsSnap.docs.forEach((val) {
        Post p = Post.fromDocument(val);
        print('-----> post = ${p.caption}');
        _timelinePosts.add(p);
      });

      for (final p in _timelinePosts) {
        setState(() {
          this.timelinePosts.add(p);
        });
      }
    }

    this.timelinePosts.sort((a, b) {
      return b.timestamp.compareTo(a.timestamp);
    });

    setState(() {
      isLoaded = true;
    });
  }

  buildTimeline() {
    return timelinePosts.length == 0
        ? Center(
            child: Text(
              "Follow user or add post to get timeline feed",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        : Column(
            children: timelinePosts,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: ListView(
        children: [
          !isLoaded ? circularProgress() : buildTimeline(),
        ],
      ),
    );
  }
}
