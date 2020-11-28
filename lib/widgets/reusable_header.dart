import 'package:flutter/material.dart';

PreferredSize header(BuildContext context,
    {bool isAppTitle = false, String title}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(45.0),
    child: AppBar(
      elevation: 0.0,
      title: Text(
        isAppTitle ? "PonderGram" : title,
        style: TextStyle(
            fontSize: isAppTitle ? 35.0 : 20,
            fontFamily: "Orbitron",
            fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
    ),
  );
}
