import 'package:flutter/material.dart';
import 'package:pondergram/widgets/reusable_header.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: false, title: "profile"),
      body: Center(
        child: Text("Profile Page"),
      ),
    );
  }
}
