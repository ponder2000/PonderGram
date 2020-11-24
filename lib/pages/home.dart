import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pondergram/models/user.dart';
import 'package:pondergram/pages/activity_feed.dart';
import 'package:pondergram/pages/create_account.dart';
import 'package:pondergram/pages/profile.dart';
import 'package:pondergram/pages/search.dart';
import 'package:pondergram/pages/timeline.dart';
import 'package:pondergram/pages/upload.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feeds');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final Reference storageRef = FirebaseStorage.instance.ref();
final DateTime timestamp = DateTime.now();

User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("Error signin in : $err");
    });

    // to auto signin if already signedin in last session
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print("Error signin in : $err");
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      print('Signed in user : $account');
      await createUserInDB();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  Future<void> createUserInDB() async {
    //check if user exist already
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();
    //if the users doesn't exist then take them to create account page and set up their profile
    if (!doc.exists) {
      final String username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      //get username from create_account and make user in users collection
      usersRef.doc(user.id).set({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp,
      });

      doc = await usersRef.doc(user.id).get();
    }

    currentUser = User.fromDocument(doc);
    print(currentUser.username);
  }

  onPressedLogOut() {
    googleSignIn.signOut();
    print("---> User signed out!");
    setState(() {
      isAuth = false;
    });
  }

  onPressedSignIn() {
    googleSignIn.signIn();
  }

  onPageChanged(int pageInd) {
    setState(() {
      this.pageIndex = pageInd;
    });
  }

  // view when sign in is done
  Widget buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          // RaisedButton(
          //   onPressed: onPressedLogOut,
          //   child: Text("LogOut"),
          // ),
          TimeLinePage(),
          ActivityFeedPage(),
          UploadPage(currentUser: currentUser),
          SearchPage(),
          ProfilePage(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(), // user can not scroll
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
        currentIndex: pageIndex,
        onTap: (val) {
          pageController.animateToPage(val,
              duration: Duration(milliseconds: 100), curve: Curves.easeIn);
        },
        activeColor: Theme.of(context).accentColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_a_photo,
              size: 35.5,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
    // return CreateAccount();
  }

  // view when sign is not done
  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).accentColor.withOpacity(0.8),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App name
            Container(
              child: Text(
                'PonderGram',
                style: TextStyle(
                  fontSize: 60.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // login button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 15.0, spreadRadius: 5.3, color: Colors.grey)
                ],
                borderRadius: BorderRadius.circular(15.0),
              ),
              height: 50,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: FlatButton(
                textColor: Colors.black,
                // color: Theme.of(context).primaryColor.withOpacity(0.6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login),
                    Text(' Sign in with Google',
                        style: TextStyle(fontSize: 20)),
                  ],
                ),
                onPressed: onPressedSignIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
