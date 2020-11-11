import 'package:flutter/material.dart';

AppBar header(BuildContext context, {bool isAppTitle = false, String title}) {
  return AppBar(
    title: Text(
      isAppTitle ? "PonderGram" : title,
      style: TextStyle(fontSize: isAppTitle ? 50.0 : 20),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
  );
}
