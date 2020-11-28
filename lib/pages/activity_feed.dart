import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/models/activity_feed_item.dart';
import 'package:pondergram/pages/home.dart';
import 'package:pondergram/widgets/loading.dart';
import 'package:pondergram/widgets/reusable_header.dart';

class ActivityFeedPage extends StatefulWidget {
  @override
  _ActivityFeedPageState createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage> {
  bool isLoading = false;

  getActivityFeed() async {
    QuerySnapshot snapshot =
        await activityFeedRef.doc(currentUser.id).collection('feedItems').get();

    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    // getActivityFeed();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      // appBar: header(context, isAppTitle: false, title: "activity"),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return circularProgress();
            print(snapshot.hasData.toString());
            List<ActivityFeedItem> feedItems = [];
            snapshot.data.docs.forEach((d) {
              feedItems.add(ActivityFeedItem.fromDocument(d));
            });
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: ListView(
                children: feedItems,
              ),
            );
          },
        ),
      ),
    );
  }
}
