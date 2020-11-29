import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pondergram/constants.dart';
import 'package:pondergram/models/user.dart';
import 'package:pondergram/pages/post.dart';
import 'package:pondergram/pages/timeline.dart';
import 'package:pondergram/widgets/loading.dart';
import 'package:pondergram/widgets/post_tile.dart';
import 'package:pondergram/widgets/reusable_header.dart';
import 'edit_profile.dart';
import 'home.dart';

class ProfilePage extends StatefulWidget {
  String profileId;
  ProfilePage({this.profileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentUserId = currentUser?.id;
  bool gridOrientation = true;
  bool isLoading = false;
  bool isFollowing = false;
  int postCount = 0;
  int followingCount = 0;
  int followersCount = 0;
  List<Post> posts = [];

  buildCountCoulumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Texturina',
            color: Theme.of(context).accentColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  editProfile() {
    print("--> Navigate to edit profile page");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfilePage(
                  currentUserId: widget.profileId,
                )));
  }

  buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 8.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 80.0),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Texturina',
            ),
          ),
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove the follower from the other user list
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
    // delete other user from following
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
    // remove notification
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // current user follows another users, update the other users followers collection
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    // add other user to following
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    // add notification of following to other users application
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser.username,
      'userId': currentUserId,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': timestamp,
    });
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      // if own profile => edit profile
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    }
    {
      // else follow or unfollow user
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 0.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(blurRadius: 10.0)],
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              children: [
                Center(
                  child: Text("",
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold)),
                ),
                // profile pic and counts and profile button
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                buildCountCoulumn("posts", postCount),
                                buildCountCoulumn("followers", followersCount),
                                buildCountCoulumn("following", followingCount),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildProfileButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // usernaem
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(user.username + ' || ' + user.displayName,
                      style: TextStyle(
                          fontFamily: 'Texturina',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                      overflow: TextOverflow.ellipsis),
                ),
                // bio
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(user.bio,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Texturina')),
                ),
                Divider(height: 4.0),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getProfileFollowing();
    getProfileFollowers();
    checkFollowing();
  }

  getProfileFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      this.followingCount = snapshot.docs.length;
    });
  }

  getProfileFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      this.followersCount = snapshot.docs.length;
    });
  }

  checkFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();

    if (doc.exists) {
      setState(() {
        isFollowing = true;
      });
    }
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      this.postCount = snapshot.docs.length;
      posts = snapshot.docs.map((e) => Post.fromDocument(e)).toList();
    });
  }

  buildProfilePost() {
    if (isLoading) return circularProgress();
    List<GridTile> gridTileList = [];
    posts.forEach((post) {
      gridTileList.add(GridTile(
          child: PostTile(
        post: post,
      )));
    });
    return gridOrientation
        ? GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            mainAxisSpacing: 1.5,
            crossAxisSpacing: 1.5,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: gridTileList,
          )
        : Column(
            children: posts,
          );
  }

  buildToggleOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.grid_on,
            size: 25.0,
            color: gridOrientation
                ? Theme.of(context).accentColor
                : Theme.of(context).accentColor.withOpacity(0.5),
          ),
          color: gridOrientation ? Theme.of(context).primaryColor : Colors.grey,
          onPressed: gridOrientation
              ? () {}
              : () {
                  setState(() {
                    gridOrientation = true;
                  });
                },
        ),
        Divider(
          height: 2.0,
          color: Colors.black,
        ),
        IconButton(
          icon: Icon(
            Icons.list,
            size: 25.0,
            color: gridOrientation
                ? Theme.of(context).accentColor.withOpacity(0.5)
                : Theme.of(context).accentColor,
          ),
          color: gridOrientation ? Colors.grey : Theme.of(context).primaryColor,
          onPressed: gridOrientation
              ? () {
                  setState(() {
                    gridOrientation = false;
                  });
                }
              : () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: header(context, isAppTitle: false, title: "PROFILE"),
        body: ListView(
          children: [
            buildProfileHeader(),
            Divider(height: 2.0),
            buildToggleOrientation(),
            Divider(height: 2.0),
            buildProfilePost(),
          ],
        ),
      ),
    );
  }
}
