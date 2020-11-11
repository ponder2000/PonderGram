import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/widgets/loading.dart';
import 'package:pondergram/widgets/reusable_header.dart';

final userRef = FirebaseFirestore.instance.collection('users');

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  getUserById() {
    final String id = "lZAPudWz7lJNzXvNIEIB";
    userRef.doc(id).get().then((value) {
      print("%%%%%%%%%%%%%%%%%%%");
      print(value.data());
      print(value.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    getUserById();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: linearProgress(),
    );
  }
}
