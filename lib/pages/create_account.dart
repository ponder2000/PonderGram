import 'dart:async';

import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController usernameController = TextEditingController();
  String username;
  bool isValidated = false;

  submit() {
    if (isValidated) {
      print("---> Username submitted!");
      formKey.currentState.save();
      SnackBar snackBar = SnackBar(content: Text("Welcome $username"));
      scaffoldKey.currentState.showSnackBar(snackBar);
      username = username.trim().toLowerCase();
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
        onPressed: submit,
        child: Icon(Icons.done),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Create account text
            Container(
              child: Text(
                "Craete Your account👇",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
            ),
            // text filed
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Form(
                key: formKey,
                child: TextFormField(
                  // autovalidate: true,
                  onSaved: (val) {
                    this.username = val;
                  },
                  validator: (val) {
                    if (val.trim().length < 4 || val.isEmpty) {
                      this.isValidated = false;
                      return "Username too short";
                    } else if (val.trim().length > 12) {
                      this.isValidated = false;
                      return "Username too long";
                    } else {
                      this.isValidated = true;
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    icon: Icon(Icons.alternate_email),
                    labelText: "username",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
