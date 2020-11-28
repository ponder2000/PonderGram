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
  bool isValidated = true;

  submit(BuildContext context) {
    setState(() {
      usernameController.text.trim().length < 4 ||
              usernameController.text.isEmpty ||
              usernameController.text.trim().length > 12
          ? isValidated = false
          : isValidated = true;
    });
    if (isValidated) {
      print("---> Username submitted!");
      formKey.currentState.save();
      SnackBar snackBar = SnackBar(content: Text("Welcome $username"));
      scaffoldKey.currentState.showSnackBar(snackBar);
      username = usernameController.text.trim().toLowerCase();
      print('---> username in CHILD widget $username');

      Navigator.pop(context, username);
    } else {
      print('--> having error validating');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
        onPressed: () => submit(context),
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Texturina'),
                  controller: usernameController,
                  onSaved: (val) {
                    this.username = val;
                  },
                  validator: (val) {
                    if (val.trim().length < 4 || val.isEmpty) {
                      setState(() {
                        this.isValidated = false;
                      });
                      return "Username too short";
                    } else if (val.trim().length > 12) {
                      setState(() {
                        this.isValidated = false;
                      });
                      return "Username too long";
                    } else {
                      setState(() {
                        this.isValidated = true;
                      });
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    icon: Icon(Icons.alternate_email, color: Colors.white),
                    labelText: "username",
                    errorText: isValidated
                        ? null
                        : "Username must be between 4 to 12 char",
                    hintText: "Set your username",
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
