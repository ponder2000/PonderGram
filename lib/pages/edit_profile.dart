import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/models/user.dart';
import 'package:pondergram/pages/home.dart';
import 'package:pondergram/widgets/loading.dart';

class EditProfilePage extends StatefulWidget {
  final String currentUserId;
  EditProfilePage({this.currentUserId});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isLoading = false;
  User user;
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isValidBio = true;
  bool isValidUsername = true;

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    this.user = User.fromDocument(doc);
    usernameController.text = user.username;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  submit() {
    setState(() {
      usernameController.text.trim().length < 4 ||
              usernameController.text.isEmpty ||
              usernameController.text.trim().length > 12
          ? isValidUsername = false
          : isValidUsername = true;

      bioController.text.trim().length > 100
          ? isValidBio = false
          : isValidBio = true;
    });

    if (isValidBio && isValidUsername) {
      usersRef.doc(widget.currentUserId).update({
        "username": usernameController.text.trim().toLowerCase(),
        "bio": bioController.text.trim(),
      });

      SnackBar snackbar = SnackBar(content: Text("Updated Successfully"));
      scaffoldKey.currentState.showSnackBar(snackbar);
    }
    // Navigator.pop(context);
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  Column buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Username",
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontFamily: 'Texturina',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            errorText: isValidUsername
                ? null
                : "Username must be between 4 to 12 char",
            hintText: "Update your usernmae",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "bio",
            style: TextStyle(
              color: Theme.of(context).accentColor,
              fontFamily: 'Texturina',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            errorText: isValidBio
                ? null
                : "Bio too long must be less than 100 characters",
            hintText: "Update your bio",
          ),
        )
      ],
    );
  }

  buildEditProfile() {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 0.0,
          actions: [
            FlatButton.icon(
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: logout,
                label: Text(
                  "LOGOUT",
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
          onPressed: submit,
          child: Icon(Icons.done, size: 30.0),
        ),
        body: isLoading
            ? circularProgress()
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                alignment: Alignment.center,
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 16.0,
                        bottom: 8.0,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: user.photoUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.contain),
                          ),
                        ),
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          buildUsernameField(),
                          buildBioField(),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Made with flutter ❤️ by Jay Saha',
                        style: TextStyle(
                          fontFamily: 'Texturina',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildEditProfile();
  }
}
