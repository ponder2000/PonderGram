import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
        onPressed: () {
          // TODO : implement after username set
          print(usernameController.text);
        },
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
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  icon: Icon(Icons.alternate_email),
                  helperText: "Enter your Username",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
