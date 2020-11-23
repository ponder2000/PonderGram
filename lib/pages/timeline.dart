import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/widgets/loading.dart';
import 'package:pondergram/widgets/reusable_header.dart';

import 'home.dart';

// final userRef = FirebaseFirestore.instance.collection('users');

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Text> children = [];
          snapshot.data.docs.forEach((d) {
            children.add(Text(d.data()['email']));
          });
          // print('-----> ${snapshot.data.docs}');
          return Container(
            child: ListView(
              children: children,
            ),
          );
        },
      ),
    );
  }
}
