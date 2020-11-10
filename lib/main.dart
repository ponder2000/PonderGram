import 'package:flutter/material.dart';

import 'pages/home.dart';

void main() {
  runApp(PonderGram());
}

class PonderGram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PonderGram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
      ),
      home: Home(),
    );
  }
}
